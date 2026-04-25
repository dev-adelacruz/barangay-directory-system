# frozen_string_literal: true

require "csv"

class EvacuationReportExporter
  CSV_HEADERS = %w[
    event_id event_name barangay_name typhoon_name scope status
    activated_at resolved_at households_affected residents_affected
    activated_by resolved_by notes
  ].freeze

  def initialize(events)
    @events = events
  end

  def export_filename(format)
    "evacuation_report_#{Time.current.strftime('%Y%m%d%H%M%S')}.#{format}"
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << CSV_HEADERS
      @events.find_each do |e|
        csv << [
          e.id, e.name, e.barangay_name, e.typhoon_name, e.scope, e.status,
          e.activated_at&.strftime("%Y-%m-%d %H:%M"), e.resolved_at&.strftime("%Y-%m-%d %H:%M"),
          e.households_affected, e.residents_affected,
          e.activated_by&.email, e.resolved_by&.email, e.notes
        ]
      end
    end
  end

  def to_pdf # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    Prawn::Document.new(page_layout: :landscape, page_size: "A4") do |pdf|
      pdf.text "Evacuation Report", size: 16, style: :bold
      pdf.move_down 8

      headers = ["Event", "Barangay", "Typhoon", "Status", "Activated At",
                 "Resolved At", "HH Affected", "Residents"]
      col_widths = [100, 90, 80, 60, 90, 90, 60, 60]

      rows = [headers] + @events.map do |e|
        [
          e.name, e.barangay_name.to_s, e.typhoon_name.to_s, e.status,
          e.activated_at&.strftime("%Y-%m-%d"),
          e.resolved_at&.strftime("%Y-%m-%d") || "—",
          e.households_affected.to_s, e.residents_affected.to_s
        ]
      end

      pdf.table(rows, column_widths: col_widths, header: true, cell_style: { size: 8 }) do
        row(0).font_style = :bold
        row(0).background_color = "DDDDDD"
      end
    end.render
  end
end
