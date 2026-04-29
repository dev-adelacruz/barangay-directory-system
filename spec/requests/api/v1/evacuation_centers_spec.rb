# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::EvacuationCenters" do
  let(:admin) { create(:user, role: :admin) }
  let(:staff) { create(:user, :staff, barangay_name: "Barangay San Isidro") }
  let(:drrmo) { create(:user, :drrmo) }

  describe "GET /api/v1/evacuation_centers" do
    before do
      create(:evacuation_center, barangay_name: "Barangay San Isidro", status: :open)
      create(:evacuation_center, :full, barangay_name: "Barangay San Isidro")
      create(:evacuation_center, barangay_name: "Barangay Santo Niño")
    end

    it "returns all centers for admin" do
      get "/api/v1/evacuation_centers", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["evacuation_centers"].length).to eq(3)
    end

    it "scopes to barangay for staff" do
      get "/api/v1/evacuation_centers", headers: auth_headers_for(staff)
      json = response.parsed_body
      expect(json["evacuation_centers"].length).to eq(2)
    end

    it "filters by status" do
      get "/api/v1/evacuation_centers", params: { status: "full" }, headers: auth_headers_for(admin)
      expect(response.parsed_body["evacuation_centers"].pluck("status").uniq).to eq(["full"])
    end

    it "filters by available only" do
      get "/api/v1/evacuation_centers", params: { available: "true" }, headers: auth_headers_for(admin)
      statuses = response.parsed_body["evacuation_centers"].pluck("status")
      expect(statuses).not_to include("full", "closed")
    end

    it "returns occupancy_percentage and available_slots" do
      get "/api/v1/evacuation_centers", headers: auth_headers_for(admin)
      center = response.parsed_body["evacuation_centers"].first
      expect(center).to include("occupancy_percentage", "available_slots")
    end

    it "returns 401 when unauthenticated" do
      get "/api/v1/evacuation_centers"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/evacuation_centers/:id" do
    let(:center) { create(:evacuation_center) }

    it "returns the center" do
      get "/api/v1/evacuation_centers/#{center.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["evacuation_center"]["id"]).to eq(center.id)
    end
  end

  describe "POST /api/v1/evacuation_centers" do
    let(:params) do
      { evacuation_center: {
        name: "New Center", barangay_name: "Barangay San Isidro",
        address: "456 Relief Road", max_capacity: 200,
        latitude: 13.58, longitude: 124.25
      } }
    end

    it "creates a center as admin" do
      post "/api/v1/evacuation_centers", params:, headers: auth_headers_for(admin)
      expect(response).to have_http_status(:created)
      expect(response.parsed_body["evacuation_center"]["name"]).to eq("New Center")
    end

    it "returns errors on invalid params" do
      post "/api/v1/evacuation_centers",
           params: { evacuation_center: { name: "", barangay_name: "X", max_capacity: -1 } },
           headers: auth_headers_for(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 403 for drrmo" do
      post "/api/v1/evacuation_centers", params:, headers: auth_headers_for(drrmo)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "PATCH /api/v1/evacuation_centers/:id/update_occupancy" do
    let(:center) { create(:evacuation_center, max_capacity: 100, current_occupancy: 30) }

    it "updates current occupancy" do
      patch "/api/v1/evacuation_centers/#{center.id}/update_occupancy",
            params: { current_occupancy: 75 },
            headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["evacuation_center"]["current_occupancy"]).to eq(75)
    end

    it "can update status along with occupancy" do
      patch "/api/v1/evacuation_centers/#{center.id}/update_occupancy",
            params: { current_occupancy: 100, status: "full" },
            headers: auth_headers_for(admin)
      json = response.parsed_body["evacuation_center"]
      expect(json["current_occupancy"]).to eq(100)
      expect(json["status"]).to eq("full")
    end

    it "rejects occupancy exceeding max_capacity" do
      patch "/api/v1/evacuation_centers/#{center.id}/update_occupancy",
            params: { current_occupancy: 200 },
            headers: auth_headers_for(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
