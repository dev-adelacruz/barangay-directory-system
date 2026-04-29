# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "GET /api/v1/dashboard/summary" do
  let(:admin) { create(:user, role: :admin) }
  let(:staff) { create(:user, :staff, barangay_name: "Barangay San Isidro") }
  let(:drrmo) { create(:user, :drrmo) }

  let(:household_a) { create(:household, barangay_name: "Barangay San Isidro", evacuation_status: :evacuated) }
  let(:household_b) { create(:household, barangay_name: "Barangay San Isidro", evacuation_status: :at_home) }
  let(:household_other) { create(:household, barangay_name: "Barangay Santo Niño", evacuation_status: :evacuated) }

  before do
    create(:resident, household: household_a, special_needs_category: :pwd)
    create(:resident, household: household_b)
    create(:resident, household: household_other)
    create(:evacuation_center, barangay_name: "Barangay San Isidro", status: :open)
    create(:evacuation_center, barangay_name: "Barangay San Isidro", status: :closed)
    create(:evacuation_center, barangay_name: "Barangay Santo Niño", status: :open)
  end

  context "when authenticated as admin" do
    it "returns summary stats across all barangays" do
      get "/api/v1/dashboard/summary", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      summary = response.parsed_body["summary"]
      expect(summary["total_households"]).to eq(3)
      expect(summary["total_residents"]).to eq(3)
      expect(summary["evacuated_households"]).to eq(2)
      expect(summary["high_risk_residents"]).to eq(1)
      expect(summary["open_evacuation_centers"]).to eq(2)
      expect(summary["total_evacuation_centers"]).to eq(3)
      expect(summary).to include("typhoon_mode_active")
    end
  end

  context "when authenticated as staff" do
    it "returns stats scoped to their barangay" do
      get "/api/v1/dashboard/summary", headers: auth_headers_for(staff)
      summary = response.parsed_body["summary"]
      expect(summary["total_households"]).to eq(2)
      expect(summary["evacuated_households"]).to eq(1)
      expect(summary["total_evacuation_centers"]).to eq(2)
      expect(summary["open_evacuation_centers"]).to eq(1)
    end
  end

  context "when typhoon mode is active" do
    before { create(:typhoon_mode_activation, barangay_name: "Barangay San Isidro", activated_by: admin) }

    it "returns typhoon_mode_active: true for staff in that barangay" do
      get "/api/v1/dashboard/summary", headers: auth_headers_for(staff)
      expect(response.parsed_body["summary"]["typhoon_mode_active"]).to be true
    end
  end

  it "returns 401 when unauthenticated" do
    get "/api/v1/dashboard/summary"
    expect(response).to have_http_status(:unauthorized)
  end
end
