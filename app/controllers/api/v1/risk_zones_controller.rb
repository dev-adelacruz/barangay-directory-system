# frozen_string_literal: true

# rubocop:disable Layout/OrderedMethods
class Api::V1::RiskZonesController < Api::V1::BaseController
  before_action :authorize_write!, only: %i[create update destroy]
  before_action :set_risk_zone, only: %i[show update destroy]

  def index
    zones = apply_filters(base_scope.order(:name))
    render json: { risk_zones: RiskZoneBlueprint.render_as_hash(zones) }
  end

  def show
    render json: { risk_zone: RiskZoneBlueprint.render_as_hash(@risk_zone) }
  end

  def create
    zone = RiskZone.new(risk_zone_params)
    if zone.save
      render json: { risk_zone: RiskZoneBlueprint.render_as_hash(zone) }, status: :created
    else
      render json: { errors: zone.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @risk_zone.update(risk_zone_params)
      render json: { risk_zone: RiskZoneBlueprint.render_as_hash(@risk_zone) }
    else
      render json: { errors: @risk_zone.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @risk_zone.destroy!
    head :no_content
  end

  private

  def apply_filters(scope)
    scope = scope.for_barangay(params[:barangay_name]) if params[:barangay_name].present?
    scope = scope.by_risk_level(params[:risk_level]) if params[:risk_level].present?
    scope
  end

  def base_scope
    scoped_barangay ? RiskZone.for_barangay(scoped_barangay) : RiskZone.all
  end

  def risk_zone_params
    params.require(:risk_zone).permit(:name, :barangay_name, :risk_level, :description, boundary: {})
  end

  def set_risk_zone
    @risk_zone = base_scope.find(params[:id])
  end
end
# rubocop:enable Layout/OrderedMethods
