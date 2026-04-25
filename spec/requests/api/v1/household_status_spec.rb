# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::Households — Status" do
  let(:staff) { create(:user, :staff, barangay_name: "Barangay San Isidro") }
  let(:drrmo) { create(:user, :drrmo) }
  let(:household) { create(:household, barangay_name: "Barangay San Isidro") }

  describe "PATCH /api/v1/households/:id/update_status" do
    context "when authenticated as staff" do
      it "updates the evacuation status" do
        patch "/api/v1/households/#{household.id}/update_status",
              params: { evacuation_status: "evacuated" },
              headers: auth_headers_for(staff)
        expect(response).to have_http_status(:ok)
        expect(household.reload.evacuation_status).to eq("evacuated")
      end

      it "records a status change entry" do
        expect do
          patch "/api/v1/households/#{household.id}/update_status",
                params: { evacuation_status: "evacuated" },
                headers: auth_headers_for(staff)
        end.to change(HouseholdStatusChange, :count).by(1)
      end

      it "returns 422 for an invalid status" do
        patch "/api/v1/households/#{household.id}/update_status",
              params: { evacuation_status: "invalid_status" },
              headers: auth_headers_for(staff)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when authenticated as drrmo" do
      it "returns 403 Forbidden" do
        patch "/api/v1/households/#{household.id}/update_status",
              params: { evacuation_status: "evacuated" },
              headers: auth_headers_for(drrmo)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /api/v1/households/:id (with status history)" do
    let(:admin) { create(:user, role: :admin) }

    before do
      create(:household_status_change, household:, user: staff,
             previous_status: :at_home, new_status: :evacuated)
    end

    it "includes status history in the show response" do
      get "/api/v1/households/#{household.id}", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json["household"]["status_changes"]).to be_an(Array)
      expect(json["household"]["status_changes"].first["new_status"]).to eq("evacuated")
    end
  end

  describe "PATCH /api/v1/households/bulk_update_status" do
    let(:first_household) { create(:household, barangay_name: "Barangay San Isidro") }
    let(:second_household) { create(:household, barangay_name: "Barangay San Isidro") }
    let(:bulk_params) do
      {
        households: [
          { id: first_household.id, evacuation_status: "pre_emptively_evacuated" },
          { id: second_household.id, evacuation_status: "evacuated" }
        ]
      }
    end

    context "when authenticated as staff" do
      it "bulk-updates statuses for multiple households" do
        patch "/api/v1/households/bulk_update_status",
              params: bulk_params, headers: auth_headers_for(staff)
        expect(response).to have_http_status(:ok)
        expect(first_household.reload.evacuation_status).to eq("pre_emptively_evacuated")
        expect(second_household.reload.evacuation_status).to eq("evacuated")
      end

      it "creates a status change record per household" do
        first_household && second_household
        expect do
          patch "/api/v1/households/bulk_update_status",
                params: bulk_params, headers: auth_headers_for(staff)
        end.to change(HouseholdStatusChange, :count).by(2)
      end
    end
  end
end
