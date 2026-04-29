# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::RiskZones" do
  let(:admin) { create(:user, role: :admin) }
  let(:staff) { create(:user, :staff, barangay_name: "Barangay San Isidro") }
  let(:drrmo) { create(:user, :drrmo) }

  let(:valid_boundary) do
    {
      type: "Polygon",
      coordinates: [[[124.24, 13.57], [124.25, 13.57], [124.25, 13.58], [124.24, 13.58], [124.24, 13.57]]]
    }
  end

  describe "GET /api/v1/risk_zones" do
    before do
      create(:risk_zone, barangay_name: "Barangay San Isidro", risk_level: :low)
      create(:risk_zone, :high, barangay_name: "Barangay San Isidro")
      create(:risk_zone, :medium, barangay_name: "Barangay Santo Niño")
    end

    it "returns all risk zones for admin" do
      get "/api/v1/risk_zones", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["risk_zones"].length).to eq(3)
    end

    it "scopes to barangay for staff" do
      get "/api/v1/risk_zones", headers: auth_headers_for(staff)
      json = response.parsed_body
      expect(json["risk_zones"].length).to eq(2)
      expect(json["risk_zones"].pluck("barangay_name").uniq).to eq(["Barangay San Isidro"])
    end

    it "filters by barangay_name" do
      get "/api/v1/risk_zones", params: { barangay_name: "Barangay Santo Niño" }, headers: auth_headers_for(admin)
      expect(response.parsed_body["risk_zones"].length).to eq(1)
    end

    it "filters by risk_level" do
      get "/api/v1/risk_zones", params: { risk_level: "high" }, headers: auth_headers_for(admin)
      json = response.parsed_body
      expect(json["risk_zones"].pluck("risk_level").uniq).to eq(["high"])
    end

    it "includes boundary GeoJSON" do
      get "/api/v1/risk_zones", headers: auth_headers_for(admin)
      zone = response.parsed_body["risk_zones"].first
      expect(zone["boundary"]).to be_a(Hash)
      expect(zone["boundary"]["type"]).to eq("Polygon")
    end

    it "returns unauthorized when unauthenticated" do
      get "/api/v1/risk_zones"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/risk_zones/:id" do
    let(:zone) { create(:risk_zone) }

    it "returns the risk zone" do
      get "/api/v1/risk_zones/#{zone.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["risk_zone"]["id"]).to eq(zone.id)
    end
  end

  describe "POST /api/v1/risk_zones" do
    let(:params) do
      { risk_zone: { name: "Flood Zone A", barangay_name: "Barangay San Isidro",
                     risk_level: "high", boundary: valid_boundary } }
    end

    it "creates a risk zone as admin" do
      post "/api/v1/risk_zones", params:, headers: auth_headers_for(admin)
      expect(response).to have_http_status(:created)
      expect(response.parsed_body["risk_zone"]["name"]).to eq("Flood Zone A")
    end

    it "rejects creation for drrmo" do
      post "/api/v1/risk_zones", params:, headers: auth_headers_for(drrmo)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns errors on invalid params" do
      post "/api/v1/risk_zones",
           params: { risk_zone: { name: "", barangay_name: "X", risk_level: "low", boundary: valid_boundary } },
           headers: auth_headers_for(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/risk_zones/:id" do
    let(:zone) { create(:risk_zone, risk_level: :low) }

    it "updates the risk level" do
      patch "/api/v1/risk_zones/#{zone.id}",
            params: { risk_zone: { risk_level: "high" } },
            headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["risk_zone"]["risk_level"]).to eq("high")
    end
  end

  describe "DELETE /api/v1/risk_zones/:id" do
    let!(:zone) { create(:risk_zone) }

    it "deletes the risk zone as admin" do
      delete "/api/v1/risk_zones/#{zone.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:no_content)
    end

    it "rejects deletion for drrmo" do
      delete "/api/v1/risk_zones/#{zone.id}", headers: auth_headers_for(drrmo)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
