# frozen_string_literal: true

require 'csv'

class HouseholdExporter
  CSV_HEADERS = %w[id household_head_name barangay_name sitio_purok member_count
                   latitude longitude evacuation_status has_pwd has_elderly
                   has_infants has_pregnant has_bedridden archived_at created_at].freeze

  PDF_COLUMNS = [
    { header: "Head of Household", field: :household_head_name, width: 120 },
    { header: "Barangay", field: :barangay_name, width: 100 },
    { header: "Sitio/Purok", field: :sitio_purok, width: 70 },
    { header: "Members", field: :member_count, width: 50 },
    { header: "Status", field: :evacuation_status, width: 80 },
    { header: "Special Needs", field: :special_needs_summary, width: 100 }
  ].freeze

  def initialize(scope)
    @scope = scope
  end

  def export_filename(format)
    timestamp = Time.current.strftime("%Y%m%d_%H%M%S")
    "households_#{timestamp}.#{format}"
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << CSV_HEADERS
      @scope.find_each do |household|
        csv << CSV_HEADERS.map { |col| household.public_send(col) }
      end
    end
  end

  def to_pdf # rubocop:disable Metrics/AbcSize
    Prawn::Document.new(page_size: "A4", page_layout: :landscape) do |pdf|
      pdf.font_size(10)
      pdf.text "Household Registry Export", size: 14, style: :bold
      pdf.text "Generated: #{Time.current.strftime('%B %d, %Y %H:%M')}", size: 9
      pdf.move_down 8

      data = build_pdf_table_data
      pdf.table(data, header: true, width: pdf.bounds.width, row_colors: %w[FFFFFF F5F5F5]) do
        row(0).background_color = "1E3A5F"
        row(0).text_color = "FFFFFF"
        row(0).font_style = :bold
        cells.padding = [4, 6]
        cells.borders = [:bottom]
        cells.border_color = "DDDDDD"
      end
    end.render
  end

  private

  def build_pdf_table_data
    headers = PDF_COLUMNS.pluck(:header)
    rows = @scope.map do |h|
      PDF_COLUMNS.map { |col| h.public_send(col[:field]).to_s }
    end
    [headers] + rows
  end
end
