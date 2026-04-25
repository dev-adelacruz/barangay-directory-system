# frozen_string_literal: true

class Resident < ApplicationRecord
  belongs_to :household

  delegate :barangay_name, to: :household
  enum :sex, { sex_unspecified: 0, male: 1, female: 2, sex_other: 3 }
  enum :special_needs_category, { no_needs: 0, pwd: 1, elderly: 2, infant: 3, pregnant: 4, bedridden: 5 }

  validates :full_name, presence: true
  validates :age, numericality: { greater_than: 0, allow_nil: true }

  scope :active, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
  scope :for_barangay, ->(barangay) { joins(:household).where(households: { barangay_name: barangay }) }
  scope :with_special_needs, -> { where.not(special_needs_category: :no_needs) }
  scope :by_name, ->(query) { where("full_name ILIKE ?", "%#{query}%") }
  scope :with_evacuation_status, ->(status) { joins(:household).where(households: { evacuation_status: status }) }

  def archive!
    update!(archived_at: Time.current)
  end

  def archived?
    archived_at.present?
  end

end
