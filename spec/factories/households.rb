# frozen_string_literal: true

FactoryBot.define do
  factory :household do
    household_head_name { Faker::Name.name }
    barangay_name { "Barangay San Isidro" }
    sitio_purok { "Purok 1" }
    member_count { rand(1..8) }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    evacuation_status { :at_home }
    has_pwd { false }
    has_elderly { false }
    has_infants { false }
    has_pregnant { false }
    has_bedridden { false }

    trait :with_special_needs do
      has_pwd { true }
      has_elderly { true }
    end

    trait :archived do
      archived_at { 1.day.ago }
    end

    trait :evacuated do
      evacuation_status { :evacuated }
    end
  end
end
