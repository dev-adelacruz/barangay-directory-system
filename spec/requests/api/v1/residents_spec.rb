# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::Residents" do
  let(:admin) { create(:user, role: :admin) }
  let(:staff) { create(:user, :staff, barangay_name: "Barangay San Isidro") }
  let(:drrmo) { create(:user, :drrmo) }
  let(:household) { create(:household, barangay_name: "Barangay San Isidro") }
  let(:other_household) { create(:household, barangay_name: "Barangay Santo Niño") }

  describe "GET /api/v1/residents" do
    before do
      create_list(:resident, 3, household:)
      create(:resident, household: other_household)
      create(:resident, :archived, household:)
    end

    context "when authenticated as admin" do
      it "returns all active residents" do
        get "/api/v1/residents", headers: auth_headers_for(admin)
        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json["residents"].length).to eq(4)
      end
    end

    context "when authenticated as staff" do
      it "returns only residents in their barangay" do
        get "/api/v1/residents", headers: auth_headers_for(staff)
        json = response.parsed_body
        expect(json["residents"].length).to eq(3)
        expect(json["residents"].all? { |r| r["barangay_name"] == "Barangay San Isidro" }).to be true
      end
    end

    context "when filtering by name" do
      it "returns matching residents" do
        create(:resident, full_name: "Juan dela Cruz", household:)
        get "/api/v1/residents", params: { name: "Juan" }, headers: auth_headers_for(admin)
        json = response.parsed_body
        expect(json["residents"].any? { |r| r["full_name"] == "Juan dela Cruz" }).to be true
      end
    end

    context "when filtering by special_needs" do
      it "returns only residents with a special needs category" do
        create(:resident, :with_pwd, household:)
        get "/api/v1/residents", params: { special_needs: true }, headers: auth_headers_for(admin)
        json = response.parsed_body
        expect(json["residents"].all? { |r| r["special_needs_category"] != "no_needs" }).to be true
      end
    end
  end

  describe "POST /api/v1/residents" do
    let(:valid_params) do
      {
        resident: {
          household_id: household.id,
          full_name: "Maria Santos",
          age: 35,
          sex: "female",
          relationship_to_head: "Spouse",
          special_needs_category: "no_needs"
        }
      }
    end

    context "when authenticated as staff" do
      it "creates a resident" do
        headers = auth_headers_for(staff)
        expect do
          post "/api/v1/residents", params: valid_params, headers:
        end.to change(Resident, :count).by(1)
        expect(response).to have_http_status(:created)
        expect(response.parsed_body["resident"]["full_name"]).to eq("Maria Santos")
      end
    end

    context "when authenticated as drrmo" do
      it "returns 403 Forbidden" do
        post "/api/v1/residents", params: valid_params, headers: auth_headers_for(drrmo)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PATCH /api/v1/residents/:id" do
    let(:resident) { create(:resident, household:) }

    context "when authenticated as staff" do
      it "updates the resident" do
        patch "/api/v1/residents/#{resident.id}",
              params: { resident: { age: 40 } },
              headers: auth_headers_for(staff)
        expect(response).to have_http_status(:ok)
        expect(resident.reload.age).to eq(40)
      end
    end
  end

  describe "PATCH /api/v1/residents/:id/archive" do
    let(:resident) { create(:resident, household:) }

    context "when authenticated as staff" do
      it "archives the resident" do
        patch "/api/v1/residents/#{resident.id}/archive", headers: auth_headers_for(staff)
        expect(response).to have_http_status(:ok)
        expect(resident.reload.archived?).to be true
      end
    end
  end
end
