# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HouseholdCsvImporter do
  let(:valid_csv) do
    <<~CSV
      household_head_name,barangay_name,member_count,sitio_purok,latitude,longitude,has_pwd,has_elderly
      Juan dela Cruz,Barangay San Isidro,4,Purok 1,13.7565,124.0457,false,true
      Maria Santos,Barangay San Isidro,3,Purok 2,13.7570,124.0460,false,false
    CSV
  end

  describe "#call" do
    it "imports valid rows and returns a summary" do
      result = described_class.new(valid_csv).call
      expect(result.imported_count).to eq(2)
      expect(result.skipped_count).to eq(0)
      expect(result.errors).to be_empty
    end

    it "creates Household records for valid rows" do
      expect { described_class.new(valid_csv).call }.to change(Household, :count).by(2)
    end

    it "skips rows where the household already exists" do
      create(:household, household_head_name: "Juan dela Cruz", barangay_name: "Barangay San Isidro")
      result = described_class.new(valid_csv).call
      expect(result.imported_count).to eq(1)
      expect(result.skipped_count).to eq(1)
    end

    it "reports duplicate rows within the CSV" do
      duplicate_csv = "#{valid_csv}Juan dela Cruz,Barangay San Isidro,2,Purok 3,,,,\n"
      result = described_class.new(duplicate_csv).call
      expect(result.errors).to include(match(/duplicate in file/))
    end

    it "returns an error for missing required columns" do
      bad_csv = "sitio_purok,latitude\nPurok 1,13.75\n"
      result = described_class.new(bad_csv).call
      expect(result.errors.first).to match(/Missing required columns/)
    end

    it "reports validation errors per row" do
      invalid_csv = "household_head_name,barangay_name,member_count\n,Barangay San Isidro,4\n"
      result = described_class.new(invalid_csv).call
      expect(result.errors).to include(match(/Row 2/))
    end

    context "with a barangay scope" do
      it "rejects rows outside the scope" do
        scoped_csv = "household_head_name,barangay_name,member_count\nPedro Reyes,Barangay Santo Niño,2\n"
        result = described_class.new(scoped_csv, barangay_scope: "Barangay San Isidro").call
        expect(result.errors).to include(match(/outside your scope/))
      end
    end
  end
end
