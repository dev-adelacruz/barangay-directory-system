# frozen_string_literal: true

class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  enum :role, { admin: 0, staff: 1, drrmo: 2 }

  validates :email, presence: true
  validates :role, presence: true
  validates :barangay_name, presence: true, if: :staff?

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :for_barangay, ->(barangay) { where(barangay_name: barangay) }

  def active_for_authentication?
    super && active?
  end

  def can_read_all_barangays?
    admin? || drrmo?
  end

  def can_write?
    admin? || staff?
  end

  def inactive_message
    active? ? super : :deactivated
  end
end
