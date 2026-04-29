# frozen_string_literal: true

class TyphoonModeActivationBlueprint < Blueprinter::Base
  identifier :id

  fields :barangay_name, :typhoon_name, :activated_at, :deactivated_at,
         :created_at, :updated_at

  field :active do |activation| # rubocop:disable Style/SymbolProc
    activation.active?
  end

  field :activated_by_name do |activation|
    activation.activated_by&.email
  end

  field :deactivated_by_name do |activation|
    activation.deactivated_by&.email
  end
end
