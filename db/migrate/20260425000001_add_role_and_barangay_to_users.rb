# frozen_string_literal: true

class AddRoleAndBarangayToUsers < ActiveRecord::Migration[7.1]
  def change
    change_table :users, bulk: true do |t|
      t.integer :role, default: 0, null: false
      t.string :barangay_name
      t.string :full_name
      t.index :role
    end
  end
end
