# frozen_string_literal: true
class UserBlueprint < Blueprinter::Base
  identifier :id

  fields :email, :role, :barangay_name, :full_name
end
