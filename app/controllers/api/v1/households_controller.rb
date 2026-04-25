# frozen_string_literal: true

# rubocop:disable Layout/OrderedMethods
class Api::V1::HouseholdsController < Api::V1::BaseController
  before_action :authorize_write!, only: %i[create update archive]
  before_action :set_household, only: %i[show update archive]

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
    render json: { household: HouseholdBlueprint.render_as_hash(@household) }
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

  private

  def apply_filters(scope) # rubocop:disable Metrics/AbcSize
    scope = scope.for_barangay(params[:barangay_name]) if params[:barangay_name].present?
    scope = scope.where(evacuation_status: params[:evacuation_status]) if params[:evacuation_status].present?
    scope = scope.with_special_needs if params[:special_needs].present?
    params[:include_archived] == "true" ? scope : scope.active
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
# rubocop:enable Layout/OrderedMethods
