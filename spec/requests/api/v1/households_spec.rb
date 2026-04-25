# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::Households" do
  let(:admin) { create(:user, role: :admin) }
  let(:staff) { create(:user, :staff, barangay_name: "Barangay San Isidro") }
  let(:drrmo) { create(:user, :drrmo) }

  describe "GET /api/v1/households" do
    before do
      create_list(:household, 3, barangay_name: "Barangay San Isidro")
      create(:household, barangay_name: "Barangay Santo Niño")
      create(:household, :archived, barangay_name: "Barangay San Isidro")
    end

    context "when authenticated as admin" do
      it "returns all active households" do
        get "/api/v1/households", headers: auth_headers_for(admin)
        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json["households"].length).to eq(4)
        expect(json["meta"]).to include("total_count")
      end

      it "excludes archived by default" do
        get "/api/v1/households", headers: auth_headers_for(admin)
        json = response.parsed_body
        expect(json["households"].none? { |h| h["archived"] }).to be true
      end

      it "filters by barangay_name" do
        get "/api/v1/households", params: { barangay_name: "Barangay San Isidro" },
            headers: auth_headers_for(admin)
        json = response.parsed_body
        expect(json["households"].all? { |h| h["barangay_name"] == "Barangay San Isidro" }).to be true
      end
    end

    context "when authenticated as staff" do
      it "returns only their barangay's households" do
        get "/api/v1/households", headers: auth_headers_for(staff)
        json = response.parsed_body
        expect(json["households"].all? { |h| h["barangay_name"] == "Barangay San Isidro" }).to be true
        expect(json["households"].length).to eq(3)
      end
    end
  end

  describe "POST /api/v1/households" do
    let(:valid_params) do
      {
        household: {
          household_head_name: "Juan dela Cruz",
          barangay_name: "Barangay San Isidro",
          sitio_purok: "Purok 2",
          member_count: 4,
          latitude: 13.7565,
          longitude: 124.0457,
          has_elderly: true
        }
      }
    end

    context "when authenticated as staff" do
      it "creates a household" do
        headers = auth_headers_for(staff)
        expect do
          post "/api/v1/households", params: valid_params, headers:
        end.to change(Household, :count).by(1)
        expect(response).to have_http_status(:created)
        json = response.parsed_body
        expect(json["household"]["household_head_name"]).to eq("Juan dela Cruz")
        expect(json["household"]["has_elderly"]).to be true
      end
    end

    context "when authenticated as drrmo" do
      it "returns 403 Forbidden" do
        post "/api/v1/households", params: valid_params, headers: auth_headers_for(drrmo)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PATCH /api/v1/households/:id" do
    let(:household) { create(:household, barangay_name: "Barangay San Isidro") }

    context "when authenticated as staff" do
      it "updates the household" do
        patch "/api/v1/households/#{household.id}",
              params: { household: { member_count: 6 } },
              headers: auth_headers_for(staff)
        expect(response).to have_http_status(:ok)
        expect(household.reload.member_count).to eq(6)
      end
    end
  end

  describe "PATCH /api/v1/households/:id/archive" do
    let(:household) { create(:household, barangay_name: "Barangay San Isidro") }

    context "when authenticated as staff" do
      it "archives the household" do
        patch "/api/v1/households/#{household.id}/archive", headers: auth_headers_for(staff)
        expect(response).to have_http_status(:ok)
        expect(household.reload.archived?).to be true
      end
    end
  end
end
