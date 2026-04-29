# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe '#validations' do
    it { is_expected.to validate_presence_of(:email) }
  end

  describe 'roles' do
    it 'defaults to admin' do
      user = build(:user)
      expect(user.role).to eq('admin')
    end

    it 'accepts staff role with barangay_name' do
      user = build(:user, :staff)
      expect(user).to be_valid
    end

    it 'requires barangay_name for staff' do
      user = build(:user, role: :staff, barangay_name: nil)
      expect(user).not_to be_valid
      expect(user.errors[:barangay_name]).to be_present
    end

    it 'does not require barangay_name for admin' do
      expect(build(:user, role: :admin, barangay_name: nil)).to be_valid
    end

    it 'does not require barangay_name for drrmo' do
      expect(build(:user, :drrmo, barangay_name: nil)).to be_valid
    end
  end

  describe '#can_write?' do
    it { expect(build(:user, role: :admin).can_write?).to be true }
    it { expect(build(:user, :staff).can_write?).to be true }
    it { expect(build(:user, :drrmo).can_write?).to be false }
  end

  describe '#can_read_all_barangays?' do
    it { expect(build(:user, role: :admin).can_read_all_barangays?).to be true }
    it { expect(build(:user, :drrmo).can_read_all_barangays?).to be true }
    it { expect(build(:user, :staff).can_read_all_barangays?).to be false }
  end
end
