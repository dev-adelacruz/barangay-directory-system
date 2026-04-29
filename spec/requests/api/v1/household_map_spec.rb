# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "GET /api/v1/households/map" do
  let(:admin) { create(:user, role: :admin) }
  let(:staff) { create(:user, :staff, barangay_name: "Barangay San Isidro") }

  let!(:geotagged) do
    create(:household, barangay_name: "Barangay San Isidro",
                       latitude: 13.5792, longitude: 124.2463)
  end
  let!(:no_coords) do
    create(:household, barangay_name: "Barangay San Isidro",
                       latitude: nil, longitude: nil)
  end
  let!(:archived) do
    create(:household, :archived, barangay_name: "Barangay San Isidro",
                                  latitude: 13.5800, longitude: 124.2470)
  end
  let!(:other_barangay) do
    create(:household, barangay_name: "Barangay Santo Niño",
                       latitude: 13.5900, longitude: 124.2550)
  end

  context "when unauthenticated" do
    it "returns unauthorized" do
      get "/api/v1/households/map"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  context "when authenticated as admin" do
    it "returns only active geotagged households" do
      get "/api/v1/households/map", headers: auth_headers_for(admin)
      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      ids = json["households"].pluck("id")
      expect(ids).to include(geotagged.id, other_barangay.id)
      expect(ids).not_to include(no_coords.id, archived.id)
    end

    it "includes map pin fields" do
      get "/api/v1/households/map", headers: auth_headers_for(admin)
      pin = response.parsed_body["households"].first
      expect(pin.keys).to include(
        "id", "latitude", "longitude", "evacuation_status",
        "household_head_name", "barangay_name", "member_count",
        "special_needs_flags"
      )
    end
  end

  context "when filtered by barangay_name" do
    it "returns only that barangay's pins" do
      get "/api/v1/households/map",
          params: { barangay_name: "Barangay San Isidro" },
          headers: auth_headers_for(admin)
      json = response.parsed_body
      expect(json["households"].pluck("barangay_name").uniq).to eq(["Barangay San Isidro"])
    end
  end

  context "when filtered by evacuation_status" do
    it "returns only households with that status" do
      geotagged.update!(evacuation_status: :evacuated)
      get "/api/v1/households/map",
          params: { evacuation_status: "evacuated" },
          headers: auth_headers_for(admin)
      json = response.parsed_body
      expect(json["households"].pluck("evacuation_status").uniq).to eq(["evacuated"])
    end
  end

  context "when filtered by special_needs" do
    it "returns only households with special needs residents" do
      geotagged.update!(has_pwd: true)
      get "/api/v1/households/map",
          params: { special_needs: "true" },
          headers: auth_headers_for(admin)
      json = response.parsed_body
      expect(json["households"].all? do |h|
        h["has_pwd"] || h["has_elderly"] || h["has_infants"] || h["has_pregnant"] || h["has_bedridden"]
      end).to be true
    end
  end

  context "when authenticated as staff" do
    it "only returns pins for their barangay" do
      get "/api/v1/households/map", headers: auth_headers_for(staff)
      json = response.parsed_body
      expect(json["households"].pluck("barangay_name").uniq).to eq(["Barangay San Isidro"])
    end
  end
end
