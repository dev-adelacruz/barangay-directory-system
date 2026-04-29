# frozen_string_literal: true

require "csv"

# rubocop:disable Layout/OrderedMethods
class Api::V1::ResidentsController < Api::V1::BaseController
  before_action :authorize_write!, only: %i[create update archive]
  before_action :set_resident, only: %i[show update archive]

  def index
    residents = apply_filters(base_scope.order(:full_name))
                  .page(params[:page]).per(params[:per_page] || 25)
    render json: {
      residents: ResidentBlueprint.render_as_hash(residents, view: :with_household),
      meta: pagination_meta(residents)
    }
  end

  def show
    render json: { resident: ResidentBlueprint.render_as_hash(@resident, view: :with_household) }
  end

  def create
    resident = Resident.new(resident_params)
    if resident.save
      render json: { resident: ResidentBlueprint.render_as_hash(resident) }, status: :created
    else
      render json: { errors: resident.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @resident.update(resident_params)
      render json: { resident: ResidentBlueprint.render_as_hash(@resident) }
    else
      render json: { errors: @resident.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def archive
    @resident.archive!
    render json: { resident: ResidentBlueprint.render_as_hash(@resident) }
  end

  def export # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    scope = apply_filters(base_scope.order(:full_name))
    csv = CSV.generate(headers: true) do |csv_obj|
      csv_obj << %w[id full_name age sex relationship_to_head special_needs_category
                    barangay_name sitio_purok evacuation_status household_head_name
                    archived_at created_at]
      scope.find_each do |r|
        csv_obj << [
          r.id, r.full_name, r.age, r.sex, r.relationship_to_head, r.special_needs_category,
          r.barangay_name, r.sitio_purok, r.evacuation_status, r.household_head_name,
          r.archived_at, r.created_at
        ]
      end
    end
    send_data csv,
              filename: "residents_#{Time.current.strftime('%Y%m%d%H%M%S')}.csv",
              type: "text/csv",
              disposition: "attachment"
  end

  private

  def apply_filters(scope) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    scope = scope.for_barangay(params[:barangay_name]) if params[:barangay_name].present?
    scope = scope.by_name(params[:name]) if params[:name].present?
    scope = scope.with_special_needs if params[:special_needs].present?
    scope = scope.where(special_needs_category: params[:special_needs_category]) if params[:special_needs_category].present?
    scope = scope.with_evacuation_status(params[:evacuation_status]) if params[:evacuation_status].present?
    scope = scope.elderly_by_age if params[:age_group] == "elderly"
    scope = scope.infant_by_age if params[:age_group] == "infant"
    params[:include_archived] == "true" ? scope : scope.active
  end

  def base_scope
    scoped_barangay ? Resident.for_barangay(scoped_barangay) : Resident.all
  end

  def pagination_meta(collection)
    {
      current_page: collection.current_page,
      per_page: collection.limit_value,
      total_count: collection.total_count,
      total_pages: collection.total_pages
    }
  end

  def resident_params
    params.require(:resident).permit(
      :household_id, :full_name, :age, :sex,
      :relationship_to_head, :special_needs_category
    )
  end

  def set_resident
    @resident = base_scope.find(params[:id])
  end
end
# rubocop:enable Layout/OrderedMethods
