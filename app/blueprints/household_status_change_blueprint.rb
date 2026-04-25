# frozen_string_literal: true

class HouseholdStatusChangeBlueprint < Blueprinter::Base
  identifier :id

  fields :previous_status, :new_status, :created_at

  association :user, blueprint: UserBlueprint
end
