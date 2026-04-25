# frozen_string_literal: true

class RiskZoneBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :barangay_name, :risk_level, :boundary, :description,
         :created_at, :updated_at
end
