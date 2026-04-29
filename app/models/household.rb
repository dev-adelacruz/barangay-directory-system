# frozen_string_literal: true

class Household < ApplicationRecord
  SPECIAL_NEEDS_FLAGS = %i[has_pwd has_elderly has_infants has_pregnant has_bedridden].freeze

  has_many :status_changes, class_name: "HouseholdStatusChange", dependent: :destroy

  enum :evacuation_status, {
    at_home: 0,
    pre_emptively_evacuated: 1,
    evacuated: 2,
    unaccounted: 3,
    returned: 4
  }

  validates :barangay_name, presence: true
  validates :household_head_name, presence: true
  validates :member_count, numericality: { greater_than: 0 }

  scope :active, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
  scope :for_barangay, ->(barangay) { where(barangay_name: barangay) }
  scope :with_special_needs, -> { where("has_pwd OR has_elderly OR has_infants OR has_pregnant OR has_bedridden") }

  def archive!
    update!(archived_at: Time.current)
  end

  def archived?
    archived_at.present?
  end

  def special_needs_flags
    SPECIAL_NEEDS_FLAGS.select { |flag| public_send(flag) }
  end

  def special_needs_summary
    flags = special_needs_flags
    flags.empty? ? "None" : flags.map { |f| f.to_s.delete_prefix("has_").capitalize }.join(", ")
  end

  def update_evacuation_status!(new_status, changed_by:)
    previous = evacuation_status
    update!(evacuation_status: new_status)
    status_changes.create!(user: changed_by, previous_status: previous, new_status:)
  end
end
