# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "GET /api/v1/evacuation_events/history" do
  let(:admin) { create(:user, role: :admin) }
  let(:staff) { create(:user, :staff, barangay_name: "Barangay San Isidro") }
  let(:drrmo) { create(:user, :drrmo) }

  before do
    create(:evacuation_event, :resolved,
           barangay_name: "Barangay San Isidro",
           activated_by: admin,
           typhoon_name: "Typhoon Rolly",
           households_affected: 45,
           residents_affected: 180)
    create(:evacuation_event, :resolved,
           barangay_name: "Barangay Santo Niño",
           activated_by: admin,
           typhoon_name: "Typhoon Ulysses",
           households_affected: 20,
           residents_affected: 80)
    create(:evacuation_event, barangay_name: "Barangay San Isidro", activated_by: admin)
  end

  it "returns only resolved events" do
    get "/api/v1/evacuation_events/history", headers: auth_headers_for(admin)
    expect(response).to have_http_status(:ok)
    statuses = response.parsed_body["evacuation_events"].pluck("status")
    expect(statuses.uniq).to eq(["resolved"])
  end

  it "includes typhoon_name, households_affected, residents_affected" do
    get "/api/v1/evacuation_events/history", headers: auth_headers_for(admin)
    event = response.parsed_body["evacuation_events"].first
    expect(event).to include("typhoon_name", "households_affected", "residents_affected")
  end

  it "scopes to staff barangay" do
    get "/api/v1/evacuation_events/history", headers: auth_headers_for(staff)
    json = response.parsed_body
    expect(json["evacuation_events"].length).to eq(1)
    expect(json["evacuation_events"].first["barangay_name"]).to eq("Barangay San Isidro")
  end

  it "drrmo can view history" do
    get "/api/v1/evacuation_events/history", headers: auth_headers_for(drrmo)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["evacuation_events"].length).to eq(2)
  end

  it "returns paginated meta" do
    get "/api/v1/evacuation_events/history", headers: auth_headers_for(admin)
    expect(response.parsed_body).to have_key("meta")
  end

  it "returns 401 when unauthenticated" do
    get "/api/v1/evacuation_events/history"
    expect(response).to have_http_status(:unauthorized)
  end
end
