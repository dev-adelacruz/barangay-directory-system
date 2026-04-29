# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "GET /api/v1/evacuation_events/export_report" do
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
    create(:evacuation_event, barangay_name: "Barangay San Isidro", activated_by: admin)
    create(:evacuation_event, :resolved,
           barangay_name: "Barangay Santo Niño",
           activated_by: admin,
           typhoon_name: "Typhoon Ulysses")
  end

  context "CSV export" do
    it "returns CSV for admin with all events" do
      get "/api/v1/evacuation_events/export_report", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
      csv = CSV.parse(response.body, headers: true)
      expect(csv.length).to eq(3)
      expect(csv.headers).to include("event_name", "typhoon_name", "households_affected")
    end

    it "scopes to staff barangay" do
      get "/api/v1/evacuation_events/export_report", headers: auth_headers_for(staff)
      csv = CSV.parse(response.body, headers: true)
      expect(csv.pluck("barangay_name").uniq).to eq(["Barangay San Isidro"])
    end

    it "drrmo can export" do
      get "/api/v1/evacuation_events/export_report", headers: auth_headers_for(drrmo)
      expect(response).to have_http_status(:ok)
    end
  end

  context "PDF export" do
    it "returns PDF for admin" do
      get "/api/v1/evacuation_events/export_report",
          params: { format: "pdf" },
          headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("application/pdf")
      expect(response.headers["Content-Disposition"]).to include("attachment")
    end
  end

  it "returns 401 when unauthenticated" do
    get "/api/v1/evacuation_events/export_report"
    expect(response).to have_http_status(:unauthorized)
  end
end
