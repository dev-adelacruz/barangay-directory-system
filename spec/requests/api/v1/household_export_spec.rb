# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::Households — Export" do
  let(:admin) { create(:user, role: :admin) }
  let(:staff) { create(:user, :staff, barangay_name: "Barangay San Isidro") }

  before do
    create_list(:household, 3, barangay_name: "Barangay San Isidro")
    create(:household, :evacuated, barangay_name: "Barangay San Isidro")
    create(:household, barangay_name: "Barangay Santo Niño")
  end

  describe "GET /api/v1/households/export" do
    context "when format is CSV (default)" do
      it "returns a CSV file with all households for admin" do
        get "/api/v1/households/export", headers: auth_headers_for(admin)
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("text/csv")
        expect(response.headers["Content-Disposition"]).to include("households_")
        expect(response.headers["Content-Disposition"]).to include(".csv")
      end

      it "includes all active households for admin" do
        get "/api/v1/households/export", headers: auth_headers_for(admin)
        rows = CSV.parse(response.body, headers: true)
        expect(rows.length).to eq(5)
      end

      it "scopes to staff's barangay" do
        get "/api/v1/households/export", headers: auth_headers_for(staff)
        rows = CSV.parse(response.body, headers: true)
        expect(rows.all? { |r| r["barangay_name"] == "Barangay San Isidro" }).to be true
      end

      it "applies evacuation_status filter" do
        get "/api/v1/households/export",
            params: { evacuation_status: "evacuated" },
            headers: auth_headers_for(admin)
        rows = CSV.parse(response.body, headers: true)
        expect(rows.length).to eq(1)
        expect(rows.first["evacuation_status"]).to eq("evacuated")
      end
    end

    context "when format is PDF" do
      it "returns a PDF file" do
        get "/api/v1/households/export",
            params: { format: "pdf" },
            headers: auth_headers_for(admin)
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("application/pdf")
        expect(response.headers["Content-Disposition"]).to include(".pdf")
        expect(response.body.start_with?("%PDF")).to be true
      end
    end
  end
end
