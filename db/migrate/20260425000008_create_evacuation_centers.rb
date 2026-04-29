# frozen_string_literal: true

class CreateEvacuationCenters < ActiveRecord::Migration[7.1]
  def change
    create_table :evacuation_centers do |t|
      t.string :name, null: false
      t.string :barangay_name, null: false
      t.string :address
      t.integer :max_capacity, null: false
      t.integer :current_occupancy, default: 0, null: false
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7
      t.integer :status, default: 0, null: false

      t.timestamps
    end

    add_index :evacuation_centers, :barangay_name
    add_index :evacuation_centers, :status
  end
end
