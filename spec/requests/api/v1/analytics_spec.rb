# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "GET /api/v1/analytics" do
  let(:admin) { create(:user, role: :admin) }
  let(:staff) { create(:user, :staff, barangay_name: "Barangay San Isidro") }
  let(:drrmo) { create(:user, :drrmo) }

  let(:household_a) { create(:household, barangay_name: "Barangay San Isidro") }
  let(:household_b) { create(:household, barangay_name: "Barangay Santo Niño") }

  before do
    create(:resident, household: household_a, special_needs_category: :pwd)
    create(:resident, household: household_a, special_needs_category: :elderly)
    create(:resident, household: household_b, special_needs_category: :no_needs)

    create(:evacuation_event, :resolved,
           barangay_name: "Barangay San Isidro",
           activated_by: admin,
           activated_at: 2.hours.ago,
           resolved_at: 1.hour.ago)
    create(:evacuation_event, :resolved,
           barangay_name: "Barangay Santo Niño",
           activated_by: admin,
           activated_at: 6.hours.ago,
           resolved_at: 4.hours.ago)
  end

  it "returns analytics for admin across all barangays" do
    get "/api/v1/analytics", headers: auth_headers_for(admin)
    expect(response).to have_http_status(:ok)
    analytics = response.parsed_body["analytics"]
    expect(analytics).to include(
      "evacuation_frequency", "average_response_time_hours",
      "special_needs_breakdown", "evacuation_status_breakdown",
      "monthly_evacuation_counts"
    )
  end

  it "returns evacuation frequency per barangay" do
    get "/api/v1/analytics", headers: auth_headers_for(admin)
    freq = response.parsed_body["analytics"]["evacuation_frequency"]
    barangays = freq.pluck("barangay_name")
    expect(barangays).to include("Barangay San Isidro", "Barangay Santo Niño")
  end

  it "returns average response time in hours" do
    get "/api/v1/analytics", headers: auth_headers_for(admin)
    avg = response.parsed_body["analytics"]["average_response_time_hours"]
    expect(avg).to be_a(Numeric)
    expect(avg).to be > 0
  end

  it "returns special_needs_breakdown with all categories" do
    get "/api/v1/analytics", headers: auth_headers_for(admin)
    breakdown = response.parsed_body["analytics"]["special_needs_breakdown"]
    expect(breakdown).to include("pwd", "elderly", "no_needs")
    expect(breakdown["pwd"]).to eq(1)
    expect(breakdown["elderly"]).to eq(1)
  end

  it "returns 12 months of monthly_evacuation_counts" do
    get "/api/v1/analytics", headers: auth_headers_for(admin)
    monthly = response.parsed_body["analytics"]["monthly_evacuation_counts"]
    expect(monthly.length).to eq(12)
    expect(monthly).to all(include("month", "count"))
  end

  it "scopes analytics to staff barangay" do
    get "/api/v1/analytics", headers: auth_headers_for(staff)
    analytics = response.parsed_body["analytics"]
    freq = analytics["evacuation_frequency"]
    expect(freq.pluck("barangay_name")).to eq(["Barangay San Isidro"])
  end

  it "drrmo can view analytics" do
    get "/api/v1/analytics", headers: auth_headers_for(drrmo)
    expect(response).to have_http_status(:ok)
  end

  it "returns 401 when unauthenticated" do
    get "/api/v1/analytics"
    expect(response).to have_http_status(:unauthorized)
  end
end
