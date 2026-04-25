# frozen_string_literal: true

module Authorizable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  def authorize_role!(*roles)
    return if current_user && roles.map(&:to_s).include?(current_user.role)

    render json: { error: "Forbidden. Required role: #{roles.join(' or ')}." }, status: :forbidden
  end

  def authorize_write!
    return if current_user&.can_write?

    render json: { error: "Forbidden. Write access requires admin or staff role." }, status: :forbidden
  end

  def scoped_barangay
    return nil if current_user.can_read_all_barangays?

    current_user.barangay_name
  end
end
