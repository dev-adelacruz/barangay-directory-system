# frozen_string_literal: true

FactoryBot.define do
  factory :evacuation_center do
    sequence(:name) { |n| "Evacuation Center #{n}" }
    barangay_name { "Barangay San Isidro" }
    address { "123 Evacuation Road" }
    max_capacity { 100 }
    current_occupancy { 0 }
    status { :open }
    latitude { 13.5792 }
    longitude { 124.2463 }

    trait :at_capacity do
      current_occupancy { 100 }
      status { :at_capacity }
    end

    trait :full do
      current_occupancy { 100 }
      status { :full }
    end

    trait :closed do
      status { :closed }
    end
  end
end
