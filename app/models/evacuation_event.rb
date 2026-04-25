# frozen_string_literal: true

class EvacuationEvent < ApplicationRecord
  belongs_to :activated_by, class_name: "User"
  belongs_to :resolved_by, class_name: "User", optional: true

  enum :scope, { barangay_wide: 0, municipality_wide: 1 }
  enum :status, { active: 0, resolved: 1 }

  validates :name, presence: true
  validates :activated_at, presence: true
  validates :barangay_name, presence: true, if: :barangay_wide?

  scope :for_barangay, ->(barangay) { where(barangay_name: barangay) }
  scope :active_events, -> { where(status: :active) }
  scope :resolved_events, -> { where(status: :resolved) }
  scope :for_typhoon, ->(name) { where(typhoon_name: name) }

  def resolve!(user, notes: nil)
    update!(resolved_by: user, resolved_at: Time.current, status: :resolved, notes:)
  end
end
