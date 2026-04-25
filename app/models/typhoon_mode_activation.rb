# frozen_string_literal: true

class TyphoonModeActivation < ApplicationRecord
  belongs_to :activated_by, class_name: "User"
  belongs_to :deactivated_by, class_name: "User", optional: true

  scope :active, -> { where(deactivated_at: nil) }
  scope :for_barangay, ->(barangay) { where(barangay_name: barangay) }
  scope :municipality_wide, -> { where(barangay_name: nil) }

  validates :activated_at, presence: true

  def active?
    deactivated_at.nil?
  end

  def deactivate!(user)
    update!(deactivated_by: user, deactivated_at: Time.current)
  end
end
