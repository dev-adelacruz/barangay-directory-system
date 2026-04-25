# frozen_string_literal: true

# rubocop:disable Layout/OrderedMethods, Metrics/ClassLength
class Api::V1::HouseholdsController < Api::V1::BaseController
  before_action :authorize_write!, only: %i[create update archive update_status bulk_update_status import assign_center]
  before_action :set_household, only: %i[show update archive update_status assign_center]

  def index
    households = base_scope.order(:household_head_name)
                            .page(params[:page]).per(params[:per_page] || 25)
    households = apply_filters(households)

    render json: {
      households: HouseholdBlueprint.render_as_hash(households),
      meta: pagination_meta(households)
    }
  end

  def show
    render json: {
      household: HouseholdBlueprint.render_as_hash(
        @household.tap { |h| h.status_changes.load },
        view: :with_status_history
      )
    }
  end

  def create
    household = Household.new(household_params)

    if household.save
      render json: { household: HouseholdBlueprint.render_as_hash(household) }, status: :created
    else
      render json: { errors: household.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @household.update(household_params)
      render json: { household: HouseholdBlueprint.render_as_hash(@household) }
    else
      render json: { errors: @household.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def archive
    @household.archive!
    render json: { household: HouseholdBlueprint.render_as_hash(@household) }
  end

  def update_status
    @household.update_evacuation_status!(params.require(:evacuation_status), changed_by: current_user)
    render json: { household: HouseholdBlueprint.render_as_hash(@household) }
  rescue ArgumentError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def export
    scope = apply_filters(base_scope.order(:household_head_name))
    exporter = HouseholdExporter.new(scope)
    format = params[:format] == "pdf" ? "pdf" : "csv"

    if format == "pdf"
      send_data exporter.to_pdf,
                filename: exporter.export_filename("pdf"),
                type: "application/pdf",
                disposition: "attachment"
    else
      send_data exporter.to_csv,
                filename: exporter.export_filename("csv"),
                type: "text/csv",
                disposition: "attachment"
    end
  end

  def csv_template
    csv = CSV.generate { |c| c << HouseholdCsvImporter::ALL_COLUMNS }
    send_data csv, filename: "household_import_template.csv", type: "text/csv", disposition: "attachment"
  end

  def import
    result = HouseholdCsvImporter.new(
      params.require(:file).read,
      barangay_scope: scoped_barangay
    ).call
    render json: { imported: result.imported_count, skipped: result.skipped_count, errors: result.errors }
  rescue CSV::MalformedCSVError => e
    render json: { error: "Invalid CSV: #{e.message}" }, status: :unprocessable_entity
  end

  def map
    scope = apply_map_filters(base_scope.active.geotagged)
    render json: { households: HouseholdBlueprint.render_as_hash(scope, view: :map_pin) }
  end

  def status_updates # rubocop:disable Metrics/AbcSize
    since = params[:since].present? ? Time.zone.parse(params[:since]) : 5.minutes.ago
    changed_ids = HouseholdStatusChange
                    .where("household_status_changes.created_at >= ?", since)
                    .then { |scope| scoped_barangay ? scope.joins(:household).where(households: { barangay_name: scoped_barangay }) : scope }
                    .distinct
                    .pluck(:household_id)

    households = base_scope.where(id: changed_ids).active.geotagged
    render json: {
      households: HouseholdBlueprint.render_as_hash(households, view: :map_pin),
      as_of: Time.current.iso8601
    }
  end

  def assign_center
    center_id = params[:evacuation_center_id].presence
    center = center_id ? EvacuationCenter.find(center_id) : nil
    @household.update!(evacuation_center: center)
    render json: { household: HouseholdBlueprint.render_as_hash(@household) }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Evacuation center not found." }, status: :not_found
  end

  def bulk_update_status # rubocop:disable Metrics/AbcSize
    updates = params.require(:households).map do |entry|
      { id: entry[:id], evacuation_status: entry[:evacuation_status] }
    end

    results = updates.filter_map do |entry|
      household = base_scope.find_by(id: entry[:id])
      next { id: entry[:id], error: "not found" } unless household

      household.update_evacuation_status!(entry[:evacuation_status], changed_by: current_user)
      { id: household.id, evacuation_status: household.evacuation_status }
    rescue ArgumentError => e
      { id: entry[:id], error: e.message }
    end

    render json: { results: }
  end

  private

  def apply_filters(scope) # rubocop:disable Metrics/AbcSize
    scope = scope.for_barangay(params[:barangay_name]) if params[:barangay_name].present?
    scope = scope.where(evacuation_status: params[:evacuation_status]) if params[:evacuation_status].present?
    scope = scope.with_special_needs if params[:special_needs].present?
    params[:include_archived] == "true" ? scope : scope.active
  end

  def apply_map_filters(scope)
    scope = scope.for_barangay(params[:barangay_name]) if params[:barangay_name].present?
    scope = scope.where(evacuation_status: params[:evacuation_status]) if params[:evacuation_status].present?
    scope = scope.with_special_needs if params[:special_needs].present?
    scope
  end

  def base_scope
    scoped_barangay ? Household.for_barangay(scoped_barangay) : Household.all
  end

  def household_params
    params.require(:household).permit(
      :barangay_name, :household_head_name, :latitude, :longitude,
      :member_count, :sitio_purok,
      :has_bedridden, :has_elderly, :has_infants, :has_pregnant, :has_pwd
    )
  end

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      per_page: collection.limit_value,
      total_count: collection.total_count,
      total_pages: collection.total_pages
    }
  end

  def set_household
    @household = base_scope.find(params[:id])
  end
end
# rubocop:enable Layout/OrderedMethods, Metrics/ClassLength
