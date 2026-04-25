# frozen_string_literal: true

# rubocop:disable Layout/OrderedMethods
class Api::V1::EvacuationCentersController < Api::V1::BaseController
  before_action :authorize_write!, only: %i[create update update_occupancy]
  before_action :set_center, only: %i[show update update_occupancy]

  def index
    centers = apply_filters(base_scope.order(:name))
    render json: { evacuation_centers: EvacuationCenterBlueprint.render_as_hash(centers) }
  end

  def show
    render json: { evacuation_center: EvacuationCenterBlueprint.render_as_hash(@center) }
  end

  def create
    center = EvacuationCenter.new(center_params)
    if center.save
      render json: { evacuation_center: EvacuationCenterBlueprint.render_as_hash(center) }, status: :created
    else
      render json: { errors: center.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @center.update(center_params)
      render json: { evacuation_center: EvacuationCenterBlueprint.render_as_hash(@center) }
    else
      render json: { errors: @center.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update_occupancy
    new_occupancy = params.require(:current_occupancy).to_i
    new_status = params[:status]

    attrs = { current_occupancy: new_occupancy }
    attrs[:status] = new_status if new_status.present?

    if @center.update(attrs)
      render json: { evacuation_center: EvacuationCenterBlueprint.render_as_hash(@center) }
    else
      render json: { errors: @center.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def apply_filters(scope)
    scope = scope.for_barangay(params[:barangay_name]) if params[:barangay_name].present?
    scope = scope.by_status(params[:status]) if params[:status].present?
    scope = scope.available if params[:available].present?
    scope
  end

  def base_scope
    scoped_barangay ? EvacuationCenter.for_barangay(scoped_barangay) : EvacuationCenter.all
  end

  def center_params
    params.require(:evacuation_center).permit(
      :name, :barangay_name, :address, :max_capacity,
      :current_occupancy, :latitude, :longitude, :status
    )
  end

  def set_center
    @center = base_scope.find(params[:id])
  end
end
# rubocop:enable Layout/OrderedMethods
