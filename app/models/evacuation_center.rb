# frozen_string_literal: true

class EvacuationCenter < ApplicationRecord
  enum :status, { open: 0, at_capacity: 1, full: 2, closed: 3 }

  validates :name, presence: true
  validates :barangay_name, presence: true
  validates :max_capacity, numericality: { greater_than: 0 }
  validates :current_occupancy, numericality: { greater_than_or_equal_to: 0 }
  validate :occupancy_within_capacity

  scope :for_barangay, ->(barangay) { where(barangay_name: barangay) }
  scope :by_status, ->(s) { where(status: s) }
  scope :available, -> { where(status: %i[open at_capacity]) }

  def available_slots
    [max_capacity - current_occupancy, 0].max
  end

  def occupancy_percentage
    return 0 if max_capacity.zero?

    (current_occupancy.to_f / max_capacity * 100).round(1)
  end

  private

  def occupancy_within_capacity
    return unless current_occupancy && max_capacity
    return unless current_occupancy > max_capacity

    errors.add(:current_occupancy, "cannot exceed max capacity (#{max_capacity})")
  end
end
