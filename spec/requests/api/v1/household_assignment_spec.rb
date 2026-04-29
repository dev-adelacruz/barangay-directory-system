# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "PATCH /api/v1/households/:id/assign_center" do
  let(:admin) { create(:user, role: :admin) }
  let(:staff) { create(:user, :staff, barangay_name: "Barangay San Isidro") }
  let(:drrmo) { create(:user, :drrmo) }
  let(:household) { create(:household, barangay_name: "Barangay San Isidro") }
  let(:center) { create(:evacuation_center, barangay_name: "Barangay San Isidro") }

  it "assigns household to an evacuation center" do
    patch "/api/v1/households/#{household.id}/assign_center",
          params: { evacuation_center_id: center.id },
          headers: auth_headers_for(admin)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["household"]["evacuation_center_id"]).to eq(center.id)
    expect(household.reload.evacuation_center_id).to eq(center.id)
  end

  it "unassigns household when evacuation_center_id is blank" do
    household.update!(evacuation_center: center)
    patch "/api/v1/households/#{household.id}/assign_center",
          params: { evacuation_center_id: "" },
          headers: auth_headers_for(admin)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["household"]["evacuation_center_id"]).to be_nil
  end

  it "returns 404 for non-existent center" do
    patch "/api/v1/households/#{household.id}/assign_center",
          params: { evacuation_center_id: 99_999 },
          headers: auth_headers_for(admin)
    expect(response).to have_http_status(:not_found)
  end

  it "staff can assign households in their barangay" do
    patch "/api/v1/households/#{household.id}/assign_center",
          params: { evacuation_center_id: center.id },
          headers: auth_headers_for(staff)
    expect(response).to have_http_status(:ok)
  end

  it "returns 403 for drrmo" do
    patch "/api/v1/households/#{household.id}/assign_center",
          params: { evacuation_center_id: center.id },
          headers: auth_headers_for(drrmo)
    expect(response).to have_http_status(:forbidden)
  end

  it "returns 401 when unauthenticated" do
    patch "/api/v1/households/#{household.id}/assign_center",
          params: { evacuation_center_id: center.id }
    expect(response).to have_http_status(:unauthorized)
  end
end
