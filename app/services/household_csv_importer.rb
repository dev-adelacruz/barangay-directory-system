# frozen_string_literal: true

require 'csv'

class HouseholdCsvImporter
  REQUIRED_COLUMNS = %w[household_head_name barangay_name member_count].freeze
  OPTIONAL_COLUMNS = %w[sitio_purok latitude longitude
                         has_pwd has_elderly has_infants has_pregnant has_bedridden].freeze
  ALL_COLUMNS = (REQUIRED_COLUMNS + OPTIONAL_COLUMNS).freeze
  BOOLEAN_COLUMNS = %w[has_pwd has_elderly has_infants has_pregnant has_bedridden].freeze

  ImportResult = Data.define(:imported_count, :skipped_count, :errors)

  def initialize(csv_data, barangay_scope: nil)
    @csv_data = csv_data
    @barangay_scope = barangay_scope
  end

  def call # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
    rows = CSV.parse(@csv_data.strip, headers: true, liberal_parsing: true)
    missing = REQUIRED_COLUMNS - rows.headers.map(&:strip).map(&:downcase)
    return ImportResult.new(imported_count: 0, skipped_count: 0, errors: [missing_columns_error(missing)]) if missing.any?

    imported = 0
    skipped = 0
    errors = []
    seen = Set.new

    rows.each_with_index do |row, idx|
      result = process_row(row, idx + 2, seen)
      case result
      when :imported then imported += 1
      when :skipped  then skipped += 1
      when String    then errors << result
      end
    end

    ImportResult.new(imported_count: imported, skipped_count: skipped, errors:)
  end

  private

  def extract_attrs(row)
    attrs = {}
    ALL_COLUMNS.each do |col|
      value = row[col]&.strip
      next if value.blank?

      attrs[col.to_sym] = BOOLEAN_COLUMNS.include?(col) ? parse_boolean(value) : value
    end
    attrs
  end

  def missing_columns_error(missing)
    "Missing required columns: #{missing.join(', ')}"
  end

  def parse_boolean(value)
    %w[true 1 yes].include?(value.downcase)
  end

  def process_row(row, line_number, seen) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity
    attrs = extract_attrs(row)
    key = [attrs[:household_head_name]&.downcase, attrs[:barangay_name]&.downcase]

    if seen.include?(key)
      return "Row #{line_number}: duplicate in file (#{attrs[:household_head_name]}, #{attrs[:barangay_name]})"
    end

    seen.add(key)

    unless @barangay_scope.nil? || attrs[:barangay_name] == @barangay_scope
      return "Row #{line_number}: barangay '#{attrs[:barangay_name]}' is outside your scope"
    end

    if Household.exists?(household_head_name: attrs[:household_head_name], barangay_name: attrs[:barangay_name])
      return :skipped
    end

    household = Household.new(attrs)
    household.save ? :imported : "Row #{line_number}: #{household.errors.full_messages.join(', ')}"
  end
end
