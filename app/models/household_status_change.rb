# frozen_string_literal: true

class HouseholdStatusChange < ApplicationRecord
  belongs_to :household
  belongs_to :user

  enum :new_status, Household.evacuation_statuses
  enum :previous_status, Household.evacuation_statuses, prefix: :was

  validates :new_status, presence: true
end
