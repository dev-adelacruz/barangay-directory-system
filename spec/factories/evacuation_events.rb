# frozen_string_literal: true

FactoryBot.define do
  factory :evacuation_event do
    sequence(:name) { |n| "Evacuation Event #{n}" }
    barangay_name { "Barangay San Isidro" }
    scope { :barangay_wide }
    status { :active }
    activated_by factory: %i[user]
    activated_at { Time.current }
    resolved_by { nil }
    resolved_at { nil }

    trait :municipality_wide do
      scope { :municipality_wide }
      barangay_name { nil }
    end

    trait :resolved do
      status { :resolved }
      resolved_by factory: %i[user]
      resolved_at { Time.current }
    end
  end
end
