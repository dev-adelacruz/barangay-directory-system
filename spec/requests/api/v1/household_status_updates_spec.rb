# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "GET /api/v1/households/status_updates" do
  let(:admin) { create(:user, role: :admin) }
  let(:staff) { create(:user, :staff, barangay_name: "Barangay San Isidro") }

  let(:household_a) { create(:household, barangay_name: "Barangay San Isidro", latitude: 13.57, longitude: 124.24) }
  let(:household_b) { create(:household, barangay_name: "Barangay Santo Niño", latitude: 13.58, longitude: 124.25) }
  let(:no_coords) { create(:household, barangay_name: "Barangay San Isidro", latitude: nil, longitude: nil) }

  before do
    household_a.update_evacuation_status!(:evacuated, changed_by: admin)
    household_b.update_evacuation_status!(:evacuated, changed_by: admin)
    no_coords.update_evacuation_status!(:evacuated, changed_by: admin)
  end

  it "returns households with recent status changes" do
    get "/api/v1/households/status_updates",
        params: { since: 1.minute.ago.iso8601 },
        headers: auth_headers_for(admin)
    expect(response).to have_http_status(:ok)
    json = response.parsed_body
    ids = json["households"].pluck("id")
    expect(ids).to include(household_a.id, household_b.id)
    expect(ids).not_to include(no_coords.id)
    expect(json).to have_key("as_of")
  end

  it "defaults to last 5 minutes when since is not provided" do
    get "/api/v1/households/status_updates", headers: auth_headers_for(admin)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["households"].length).to be >= 2
  end

  it "scopes to staff barangay" do
    get "/api/v1/households/status_updates",
        params: { since: 1.minute.ago.iso8601 },
        headers: auth_headers_for(staff)
    ids = response.parsed_body["households"].pluck("id")
    expect(ids).to include(household_a.id)
    expect(ids).not_to include(household_b.id)
  end

  it "returns empty when no recent changes" do
    get "/api/v1/households/status_updates",
        params: { since: 1.minute.from_now.iso8601 },
        headers: auth_headers_for(admin)
    expect(response.parsed_body["households"]).to be_empty
  end

  it "returns 401 when unauthenticated" do
    get "/api/v1/households/status_updates"
    expect(response).to have_http_status(:unauthorized)
  end
end
