# frozen_string_literal: true

# rubocop:disable Layout/OrderedMethods
class Api::V1::TyphoonModeController < Api::V1::BaseController
  before_action :authorize_write!

  def status
    activations = active_scope
    render json: {
      active: activations.exists?,
      activations: TyphoonModeActivationBlueprint.render_as_hash(activations)
    }
  end

  def activate
    if active_scope.exists?
      return render json: { error: "Typhoon mode is already active for this scope." },
                    status: :unprocessable_entity
    end

    activation = TyphoonModeActivation.create!(
      activated_by: current_user,
      barangay_name: activation_scope,
      typhoon_name: params[:typhoon_name],
      activated_at: Time.current
    )
    render json: { activation: TyphoonModeActivationBlueprint.render_as_hash(activation) },
           status: :created
  end

  def deactivate
    activation = active_scope.order(activated_at: :desc).first
    return render json: { error: "No active typhoon mode found." }, status: :not_found unless activation

    activation.deactivate!(current_user)
    render json: { activation: TyphoonModeActivationBlueprint.render_as_hash(activation) }
  end

  private

  def activation_scope
    return nil if params[:municipality_wide] == "true"

    scoped_barangay || params[:barangay_name].presence
  end

  def active_scope
    scope = TyphoonModeActivation.active
    target = activation_scope
    target ? scope.for_barangay(target) : scope.municipality_wide
  end
end
# rubocop:enable Layout/OrderedMethods
