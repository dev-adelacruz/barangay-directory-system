# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    password { SecureRandom.hex }
    role { :admin }
    full_name { Faker::Name.name }
    barangay_name { nil }

    trait :staff do
      role { :staff }
      barangay_name { "Barangay San Isidro" }
    end

    trait :drrmo do
      role { :drrmo }
    end
  end
end
