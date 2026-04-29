# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Api::V1::Households — CSV Import" do
  let(:staff) { create(:user, :staff, barangay_name: "Barangay San Isidro") }
  let(:drrmo) { create(:user, :drrmo) }

  let(:valid_csv_content) do
    <<~CSV
      household_head_name,barangay_name,member_count,sitio_purok
      Juan dela Cruz,Barangay San Isidro,4,Purok 1
      Maria Santos,Barangay San Isidro,3,Purok 2
    CSV
  end

  def csv_upload(content, filename: "import.csv")
    Rack::Test::UploadedFile.new(
      StringIO.new(content),
      "text/csv",
      original_filename: filename
    )
  end

  describe "GET /api/v1/households/csv_template" do
    it "returns a CSV template with correct headers" do
      get "/api/v1/households/csv_template", headers: auth_headers_for(staff)
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include("text/csv")
      headers_row = CSV.parse(response.body).first
      expect(headers_row).to include("household_head_name", "barangay_name", "member_count")
    end
  end

  describe "POST /api/v1/households/import" do
    context "when authenticated as staff" do
      it "imports valid rows and returns a summary" do
        post "/api/v1/households/import",
             params: { file: csv_upload(valid_csv_content) },
             headers: auth_headers_for(staff)
        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json["imported"]).to eq(2)
        expect(json["skipped"]).to eq(0)
        expect(json["errors"]).to be_empty
      end

      it "creates Household records" do
        expect do
          post "/api/v1/households/import",
               params: { file: csv_upload(valid_csv_content) },
               headers: auth_headers_for(staff)
        end.to change(Household, :count).by(2)
      end

      it "reports errors for invalid rows" do
        bad_csv = "household_head_name,barangay_name,member_count\n,Barangay San Isidro,4\n"
        post "/api/v1/households/import",
             params: { file: csv_upload(bad_csv) },
             headers: auth_headers_for(staff)
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body["errors"]).not_to be_empty
      end
    end

    context "when authenticated as drrmo" do
      it "returns 403 Forbidden" do
        post "/api/v1/households/import",
             params: { file: csv_upload(valid_csv_content) },
             headers: auth_headers_for(drrmo)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
