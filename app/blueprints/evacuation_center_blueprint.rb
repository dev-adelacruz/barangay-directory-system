# frozen_string_literal: true

class EvacuationCenterBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :barangay_name, :address, :max_capacity, :current_occupancy,
         :latitude, :longitude, :status, :created_at, :updated_at

  field :occupancy_percentage
  field :available_slots
end
