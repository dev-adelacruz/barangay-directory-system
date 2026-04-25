# frozen_string_literal: true

class CreateHouseholds < ActiveRecord::Migration[7.1]
  def change # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    create_table :households do |t|
      t.string :household_head_name, null: false
      t.string :barangay_name, null: false
      t.string :sitio_purok
      t.integer :member_count, default: 1, null: false
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7
      t.integer :evacuation_status, default: 0, null: false
      t.boolean :has_pwd, default: false, null: false
      t.boolean :has_elderly, default: false, null: false
      t.boolean :has_infants, default: false, null: false
      t.boolean :has_pregnant, default: false, null: false
      t.boolean :has_bedridden, default: false, null: false
      t.datetime :archived_at

      t.timestamps
    end

    add_index :households, :barangay_name
    add_index :households, :evacuation_status
    add_index :households, :archived_at
  end
end
