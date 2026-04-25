# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::EvacuationEvents" do
  let(:admin) { create(:user, role: :admin) }
  let(:staff) { create(:user, :staff, barangay_name: "Barangay San Isidro") }
  let(:drrmo) { create(:user, :drrmo) }

  describe "GET /api/v1/evacuation_events" do
    before do
      create(:evacuation_event, barangay_name: "Barangay San Isidro", activated_by: admin)
      create(:evacuation_event, :resolved, barangay_name: "Barangay San Isidro", activated_by: admin)
      create(:evacuation_event, barangay_name: "Barangay Santo Niño", activated_by: admin)
    end

    it "returns all events for admin" do
      get "/api/v1/evacuation_events", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["evacuation_events"].length).to eq(3)
    end

    it "scopes to barangay for staff" do
      get "/api/v1/evacuation_events", headers: auth_headers_for(staff)
      expect(response.parsed_body["evacuation_events"].length).to eq(2)
    end

    it "filters by status" do
      get "/api/v1/evacuation_events", params: { status: "active" }, headers: auth_headers_for(admin)
      expect(response.parsed_body["evacuation_events"].pluck("status").uniq).to eq(["active"])
    end

    it "returns meta pagination" do
      get "/api/v1/evacuation_events", headers: auth_headers_for(admin)
      expect(response.parsed_body).to have_key("meta")
    end
  end

  describe "POST /api/v1/evacuation_events" do
    let(:params) do
      { evacuation_event: { name: "Typhoon Rolly Response", barangay_name: "Barangay San Isidro" } }
    end

    it "creates an evacuation event as admin" do
      post "/api/v1/evacuation_events", params:, headers: auth_headers_for(admin)
      expect(response).to have_http_status(:created)
      json = response.parsed_body["evacuation_event"]
      expect(json["name"]).to eq("Typhoon Rolly Response")
      expect(json["status"]).to eq("active")
      expect(json["activated_by_email"]).to eq(admin.email)
    end

    it "creates municipality-wide event" do
      post "/api/v1/evacuation_events",
           params: { evacuation_event: { name: "Municipality Alert", scope: "municipality_wide" } },
           headers: auth_headers_for(admin)
      expect(response).to have_http_status(:created)
      expect(response.parsed_body["evacuation_event"]["scope"]).to eq("municipality_wide")
    end

    it "returns 403 for drrmo" do
      post "/api/v1/evacuation_events", params:, headers: auth_headers_for(drrmo)
      expect(response).to have_http_status(:forbidden)
    end

    it "returns errors on missing name" do
      post "/api/v1/evacuation_events",
           params: { evacuation_event: { barangay_name: "X" } },
           headers: auth_headers_for(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/evacuation_events/:id/resolve" do
    let!(:event) { create(:evacuation_event, barangay_name: "Barangay San Isidro", activated_by: admin) }

    it "resolves an active event" do
      patch "/api/v1/evacuation_events/#{event.id}/resolve",
            params: { notes: "Typhoon passed, all clear." },
            headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      json = response.parsed_body["evacuation_event"]
      expect(json["status"]).to eq("resolved")
      expect(json["resolved_by_email"]).to eq(admin.email)
      expect(json["notes"]).to eq("Typhoon passed, all clear.")
    end

    it "returns error when already resolved" do
      event.resolve!(admin)
      patch "/api/v1/evacuation_events/#{event.id}/resolve",
            headers: auth_headers_for(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 403 for drrmo" do
      patch "/api/v1/evacuation_events/#{event.id}/resolve", headers: auth_headers_for(drrmo)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
