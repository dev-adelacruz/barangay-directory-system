# frozen_string_literal: true

FactoryBot.define do
  factory :typhoon_mode_activation do
    activated_by factory: %i[user]
    barangay_name { "Barangay San Isidro" }
    typhoon_name { "Typhoon Unding" }
    activated_at { Time.current }
    deactivated_at { nil }
    deactivated_by { nil }

    trait :municipality_wide do
      barangay_name { nil }
    end

    trait :deactivated do
      deactivated_by factory: %i[user]
      deactivated_at { Time.current }
    end
  end
end
