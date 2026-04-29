# frozen_string_literal: true

class ResidentBlueprint < Blueprinter::Base
  identifier :id

  fields :full_name, :age, :sex, :relationship_to_head,
         :special_needs_category, :archived_at, :created_at, :updated_at

  field :barangay_name
  field :household_id
  field :archived do |resident| # rubocop:disable Style/SymbolProc
    resident.archived?
  end

  view :with_household do
    fields :household_head_name, :sitio_purok, :evacuation_status
  end
end
