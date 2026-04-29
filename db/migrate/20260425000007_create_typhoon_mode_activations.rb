# frozen_string_literal: true

class CreateTyphoonModeActivations < ActiveRecord::Migration[7.1]
  def change
    create_table :typhoon_mode_activations do |t|
      t.references :activated_by, null: false, foreign_key: { to_table: :users }
      t.references :deactivated_by, null: true, foreign_key: { to_table: :users }
      t.string :barangay_name
      t.string :typhoon_name
      t.datetime :activated_at, null: false
      t.datetime :deactivated_at

      t.timestamps
    end

    add_index :typhoon_mode_activations, :barangay_name
    add_index :typhoon_mode_activations, :deactivated_at
  end
end
