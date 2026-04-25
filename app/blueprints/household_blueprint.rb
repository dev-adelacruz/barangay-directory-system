# frozen_string_literal: true

class HouseholdBlueprint < Blueprinter::Base
  identifier :id

  fields :household_head_name, :barangay_name, :sitio_purok,
         :member_count, :latitude, :longitude,
         :evacuation_status, :archived_at, :created_at, :updated_at,
         :has_pwd, :has_elderly, :has_infants, :has_pregnant, :has_bedridden

  field :special_needs_flags
  field :archived do |household| # rubocop:disable Style/SymbolProc
    household.archived?
  end

  view :with_status_history do
    association :status_changes, blueprint: HouseholdStatusChangeBlueprint
  end
end
