# frozen_string_literal: true

class CreateEvacuationEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :evacuation_events do |t|
      t.string :name, null: false
      t.string :barangay_name
      t.integer :scope, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.references :activated_by, null: false, foreign_key: { to_table: :users }
      t.references :resolved_by, null: true, foreign_key: { to_table: :users }
      t.datetime :activated_at, null: false
      t.datetime :resolved_at
      t.text :notes

      t.timestamps
    end

    add_index :evacuation_events, :status
    add_index :evacuation_events, :barangay_name
    add_index :evacuation_events, :activated_at
  end
end
