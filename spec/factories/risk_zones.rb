# frozen_string_literal: true

FactoryBot.define do
  factory :risk_zone do
    sequence(:name) { |n| "Risk Zone #{n}" }
    barangay_name { "Barangay San Isidro" }
    risk_level { :low }
    boundary do
      {
        "type" => "Polygon",
        "coordinates" => [[[124.24, 13.57], [124.25, 13.57], [124.25, 13.58], [124.24, 13.58], [124.24, 13.57]]]
      }
    end
    description { "A test risk zone" }

    trait :medium do
      risk_level { :medium }
    end

    trait :high do
      risk_level { :high }
    end
  end
end
