# frozen_string_literal: true

class EvacuationEventBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :barangay_name, :scope, :status, :typhoon_name,
         :households_affected, :residents_affected,
         :activated_at, :resolved_at, :notes, :created_at, :updated_at

  field :activated_by_email do |event|
    event.activated_by&.email
  end

  field :resolved_by_email do |event|
    event.resolved_by&.email
  end
end
