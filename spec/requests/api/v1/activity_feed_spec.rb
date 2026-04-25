# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "GET /api/v1/activity_feed" do
  let(:admin) { create(:user, role: :admin) }
  let(:staff) { create(:user, :staff, barangay_name: "Barangay San Isidro") }

  let(:household_a) { create(:household, barangay_name: "Barangay San Isidro") }
  let(:household_other) { create(:household, barangay_name: "Barangay Santo Niño") }

  before do
    household_a.update_evacuation_status!(:evacuated, changed_by: admin)
    household_other.update_evacuation_status!(:evacuated, changed_by: admin)
    create(:evacuation_event, barangay_name: "Barangay San Isidro", activated_by: admin, name: "Rolly Response")
    create(:typhoon_mode_activation, barangay_name: "Barangay San Isidro", activated_by: admin, typhoon_name: "Rolly")
  end

  it "returns a unified activity feed for admin" do
    get "/api/v1/activity_feed", headers: auth_headers_for(admin)
    expect(response).to have_http_status(:ok)
    activities = response.parsed_body["activities"]
    types = activities.pluck("type").uniq
    expect(types).to include("household_status_change", "evacuation_event", "typhoon_mode")
  end

  it "includes description, occurred_at, changed_by" do
    get "/api/v1/activity_feed", headers: auth_headers_for(admin)
    activity = response.parsed_body["activities"].first
    expect(activity).to include("type", "occurred_at", "description", "changed_by")
  end

  it "scopes to staff barangay" do
    get "/api/v1/activity_feed", headers: auth_headers_for(staff)
    activities = response.parsed_body["activities"]
    barangay_names = activities.filter_map { |a| a["barangay_name"] }.uniq
    expect(barangay_names).not_to include("Barangay Santo Niño")
  end

  it "returns sorted by occurred_at descending" do
    get "/api/v1/activity_feed", headers: auth_headers_for(admin)
    times = response.parsed_body["activities"].pluck("occurred_at")
    expect(times).to eq(times.sort.reverse)
  end

  it "returns 401 when unauthenticated" do
    get "/api/v1/activity_feed"
    expect(response).to have_http_status(:unauthorized)
  end
end
