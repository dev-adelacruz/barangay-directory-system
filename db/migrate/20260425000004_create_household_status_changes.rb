# frozen_string_literal: true

class CreateHouseholdStatusChanges < ActiveRecord::Migration[7.1]
  def change
    create_table :household_status_changes do |t|
      t.references :household, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :previous_status
      t.integer :new_status, null: false
      t.timestamps
    end

    add_index :household_status_changes, :new_status
    add_index :household_status_changes, :created_at
  end
end
