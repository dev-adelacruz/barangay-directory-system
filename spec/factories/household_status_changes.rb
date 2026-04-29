# frozen_string_literal: true

FactoryBot.define do
  factory :household_status_change do
    household
    user
    previous_status { :at_home }
    new_status { :evacuated }
  end
end
