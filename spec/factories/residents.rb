# frozen_string_literal: true

FactoryBot.define do
  factory :resident do
    household
    full_name { Faker::Name.name }
    age { rand(1..80) }
    sex { :male }
    relationship_to_head { "Child" }
    special_needs_category { :no_needs }

    trait :with_pwd do
      special_needs_category { :pwd }
    end

    trait :elderly do
      special_needs_category { :elderly }
      age { rand(60..90) }
    end

    trait :archived do
      archived_at { 1.day.ago }
    end
  end
end
