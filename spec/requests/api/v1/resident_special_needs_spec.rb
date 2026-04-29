# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::Residents — Special Needs & Export" do
  let(:admin) { create(:user, role: :admin) }
  let(:staff) { create(:user, :staff, barangay_name: "Barangay San Isidro") }
  let(:household) { create(:household, barangay_name: "Barangay San Isidro") }

  describe "GET /api/v1/residents — special needs filters" do
    before do
      create(:resident, full_name: "PWD Resident", special_needs_category: :pwd, household:)
      create(:resident, full_name: "Elderly Resident", special_needs_category: :elderly, age: 65, household:)
      create(:resident, full_name: "Pregnant Resident", special_needs_category: :pregnant, household:)
      create(:resident, full_name: "Normal Resident", special_needs_category: :no_needs, household:)
    end

    context "when filtering by special_needs" do
      it "returns only residents with any special needs" do
        get "/api/v1/residents", params: { special_needs: "true" }, headers: auth_headers_for(admin)
        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json["residents"].length).to eq(3)
        expect(json["residents"].pluck("special_needs_category")).not_to include("no_needs")
      end
    end

    context "when filtering by special_needs_category" do
      it "returns only residents matching the category" do
        get "/api/v1/residents", params: { special_needs_category: "pwd" }, headers: auth_headers_for(admin)
        json = response.parsed_body
        expect(json["residents"].length).to eq(1)
        expect(json["residents"].first["full_name"]).to eq("PWD Resident")
      end
    end

    context "when filtering by age_group=elderly" do
      it "returns residents aged 60 and above" do
        create(:resident, full_name: "Young Resident", age: 30, household:)
        get "/api/v1/residents", params: { age_group: "elderly" }, headers: auth_headers_for(admin)
        json = response.parsed_body
        expect(json["residents"].all? { |r| r["age"] >= 60 }).to be true
      end
    end

    context "when filtering by age_group=infant" do
      it "returns residents aged 2 and under" do
        create(:resident, full_name: "Infant Resident", age: 1, household:)
        create(:resident, full_name: "Toddler Resident", age: 3, household:)
        get "/api/v1/residents", params: { age_group: "infant" }, headers: auth_headers_for(admin)
        json = response.parsed_body
        expect(json["residents"].all? { |r| r["age"] <= 2 }).to be true
      end
    end
  end

  describe "GET /api/v1/residents — household fields in response" do
    it "includes household_head_name, sitio_purok, and evacuation_status" do
      create(:resident, household:)
      get "/api/v1/residents", headers: auth_headers_for(admin)
      json = response.parsed_body
      resident = json["residents"].first
      expect(resident).to include("household_head_name", "sitio_purok", "evacuation_status")
    end
  end

  describe "GET /api/v1/residents/:id" do
    it "includes household fields" do
      resident = create(:resident, household:)
      get "/api/v1/residents/#{resident.id}", headers: auth_headers_for(admin)
      json = response.parsed_body
      expect(json["resident"]).to include("household_head_name", "sitio_purok", "evacuation_status")
    end
  end

  describe "GET /api/v1/residents/export" do
    before do
      create(:resident, full_name: "Export Person", special_needs_category: :pwd, household:)
      create(:resident, full_name: "Another Person", special_needs_category: :no_needs, household:)
    end

    context "when authenticated as admin" do
      it "returns a CSV file with resident data" do
        get "/api/v1/residents/export", headers: auth_headers_for(admin)
        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include("text/csv")
        expect(response.headers["Content-Disposition"]).to include("attachment")
        csv = CSV.parse(response.body, headers: true)
        expect(csv.length).to eq(2)
        expect(csv.headers).to include("full_name", "special_needs_category", "barangay_name")
      end
    end

    context "when filtered by special_needs_category" do
      it "exports only matching residents" do
        get "/api/v1/residents/export", params: { special_needs_category: "pwd" }, headers: auth_headers_for(admin)
        csv = CSV.parse(response.body, headers: true)
        expect(csv.length).to eq(1)
        expect(csv.first["full_name"]).to eq("Export Person")
      end
    end

    context "when authenticated as staff" do
      let(:other_household) { create(:household, barangay_name: "Barangay Santo Niño") }

      it "only exports residents in their barangay" do
        create(:resident, full_name: "Other Barangay", household: other_household)
        get "/api/v1/residents/export", headers: auth_headers_for(staff)
        csv = CSV.parse(response.body, headers: true)
        expect(csv.pluck("barangay_name").uniq).to eq(["Barangay San Isidro"])
      end
    end

    context "when unauthenticated" do
      it "returns unauthorized" do
        get "/api/v1/residents/export"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
