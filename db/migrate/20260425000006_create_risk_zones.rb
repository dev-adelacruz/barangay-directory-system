# frozen_string_literal: true

class CreateRiskZones < ActiveRecord::Migration[7.1]
  def change
    create_table :risk_zones do |t|
      t.string :name, null: false
      t.string :barangay_name, null: false
      t.integer :risk_level, default: 0, null: false
      t.jsonb :boundary, null: false, default: {}
      t.text :description

      t.timestamps
    end

    add_index :risk_zones, :barangay_name
    add_index :risk_zones, :risk_level
  end
end
