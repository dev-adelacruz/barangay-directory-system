# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::TyphoonMode" do
  let(:admin) { create(:user, role: :admin) }
  let(:staff) { create(:user, :staff, barangay_name: "Barangay San Isidro") }
  let(:drrmo) { create(:user, :drrmo) }

  describe "GET /api/v1/typhoon_mode" do
    context "when no typhoon mode is active" do
      it "returns active: false" do
        get "/api/v1/typhoon_mode", headers: auth_headers_for(admin)
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["active"]).to be false
        expect(response.parsed_body["activations"]).to be_empty
      end
    end

    context "when typhoon mode is active" do
      before { create(:typhoon_mode_activation, :municipality_wide, activated_by: admin) }

      it "returns active: true with activations" do
        get "/api/v1/typhoon_mode",
            params: { municipality_wide: "true" },
            headers: auth_headers_for(admin)
        json = response.parsed_body
        expect(json["active"]).to be true
        expect(json["activations"].first["active"]).to be true
        expect(json["activations"].first["typhoon_name"]).to eq("Typhoon Unding")
      end
    end

    it "returns 403 for drrmo" do
      get "/api/v1/typhoon_mode", headers: auth_headers_for(drrmo)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/v1/typhoon_mode/activate" do
    it "activates typhoon mode for a barangay as admin" do
      post "/api/v1/typhoon_mode/activate",
           params: { barangay_name: "Barangay San Isidro", typhoon_name: "Tropical Storm Ambo" },
           headers: auth_headers_for(admin)
      expect(response).to have_http_status(:created)
      json = response.parsed_body
      expect(json["activation"]["active"]).to be true
      expect(json["activation"]["typhoon_name"]).to eq("Tropical Storm Ambo")
    end

    it "activates municipality-wide typhoon mode" do
      post "/api/v1/typhoon_mode/activate",
           params: { municipality_wide: "true", typhoon_name: "Typhoon Rolly" },
           headers: auth_headers_for(admin)
      expect(response).to have_http_status(:created)
      expect(response.parsed_body["activation"]["barangay_name"]).to be_nil
    end

    it "returns error if already active" do
      create(:typhoon_mode_activation, barangay_name: "Barangay San Isidro", activated_by: admin)
      post "/api/v1/typhoon_mode/activate",
           params: { barangay_name: "Barangay San Isidro" },
           headers: auth_headers_for(admin)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "staff can activate for their own barangay" do
      post "/api/v1/typhoon_mode/activate",
           params: { typhoon_name: "Typhoon Ulysses" },
           headers: auth_headers_for(staff)
      expect(response).to have_http_status(:created)
      expect(response.parsed_body["activation"]["barangay_name"]).to eq("Barangay San Isidro")
    end

    it "returns 403 for drrmo" do
      post "/api/v1/typhoon_mode/activate",
           params: { barangay_name: "Barangay San Isidro" },
           headers: auth_headers_for(drrmo)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/v1/typhoon_mode/deactivate" do
    context "when typhoon mode is active" do
      let!(:activation) do
        create(:typhoon_mode_activation, barangay_name: "Barangay San Isidro", activated_by: admin)
      end

      it "deactivates typhoon mode" do
        post "/api/v1/typhoon_mode/deactivate",
             params: { barangay_name: "Barangay San Isidro" },
             headers: auth_headers_for(admin)
        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json["activation"]["active"]).to be false
        expect(json["activation"]["deactivated_by_name"]).to eq(admin.email)
      end
    end

    context "when typhoon mode is not active" do
      it "returns 404" do
        post "/api/v1/typhoon_mode/deactivate",
             params: { barangay_name: "Barangay San Isidro" },
             headers: auth_headers_for(admin)
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
