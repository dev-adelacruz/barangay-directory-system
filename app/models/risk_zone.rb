# frozen_string_literal: true

class RiskZone < ApplicationRecord
  enum :risk_level, { low: 0, medium: 1, high: 2 }

  validates :name, presence: true
  validates :barangay_name, presence: true
  validates :boundary, presence: true

  scope :for_barangay, ->(barangay) { where(barangay_name: barangay) }
  scope :by_risk_level, ->(level) { where(risk_level: level) }
end
