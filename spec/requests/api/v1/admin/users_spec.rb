# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::Admin::Users" do
  let(:admin) { create(:user, role: :admin) }
  let(:staff) { create(:user, :staff) }
  let(:drrmo) { create(:user, :drrmo) }

  describe "GET /api/v1/admin/users" do
    before { create_list(:user, 3, :staff) }

    context "when authenticated as admin" do
      it "returns paginated users" do
        get "/api/v1/admin/users", headers: auth_headers_for(admin)
        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json["users"]).to be_an(Array)
        expect(json["meta"]).to include("total_count", "current_page")
      end

      it "filters by search query" do
        create(:user, email: "unique_search@example.com")
        get "/api/v1/admin/users", params: { search: "unique_search" }, headers: auth_headers_for(admin)
        json = response.parsed_body
        expect(json["users"].pluck("email")).to include("unique_search@example.com")
      end
    end

    context "when authenticated as staff" do
      it "returns 403 Forbidden" do
        get "/api/v1/admin/users", headers: auth_headers_for(staff)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "without authentication" do
      it "returns 401" do
        get "/api/v1/admin/users"
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "POST /api/v1/admin/users" do
    let(:valid_params) { { user: { email: "new@test.com", role: "staff", barangay_name: "San Isidro", full_name: "Test User" } } }

    context "when authenticated as admin" do
      it "creates a user" do
        headers = auth_headers_for(admin)
        expect do
          post "/api/v1/admin/users", params: valid_params, headers:
        end.to change(User, :count).by(1)
        expect(response).to have_http_status(:created)
      end

      it "returns errors for invalid data" do
        post "/api/v1/admin/users",
             params: { user: { email: "", role: "staff" } },
             headers: auth_headers_for(admin)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /api/v1/admin/users/:id" do
    context "when authenticated as admin" do
      it "updates a user's role" do
        patch "/api/v1/admin/users/#{staff.id}",
              params: { user: { role: "drrmo", barangay_name: nil } },
              headers: auth_headers_for(admin)
        expect(response).to have_http_status(:ok)
        expect(staff.reload.role).to eq("drrmo")
      end
    end
  end

  describe "PATCH /api/v1/admin/users/:id/deactivate" do
    context "when authenticated as admin" do
      it "deactivates a user" do
        patch "/api/v1/admin/users/#{staff.id}/deactivate", headers: auth_headers_for(admin)
        expect(response).to have_http_status(:ok)
        expect(staff.reload.active).to be false
      end
    end
  end

  describe "PATCH /api/v1/admin/users/:id/reactivate" do
    let(:inactive_user) { create(:user, :staff, active: false) }

    context "when authenticated as admin" do
      it "reactivates a user" do
        patch "/api/v1/admin/users/#{inactive_user.id}/reactivate", headers: auth_headers_for(admin)
        expect(response).to have_http_status(:ok)
        expect(inactive_user.reload.active).to be true
      end
    end
  end

  describe "DELETE /api/v1/admin/users/:id" do
    context "when authenticated as admin" do
      it "deletes another user" do
        target = create(:user, :staff)
        headers = auth_headers_for(admin)
        expect do
          delete "/api/v1/admin/users/#{target.id}", headers:
        end.to change(User, :count).by(-1)
        expect(response).to have_http_status(:no_content)
      end

      it "cannot delete own account" do
        delete "/api/v1/admin/users/#{admin.id}", headers: auth_headers_for(admin)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
