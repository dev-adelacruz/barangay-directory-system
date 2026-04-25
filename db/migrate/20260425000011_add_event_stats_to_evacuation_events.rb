# frozen_string_literal: true

class AddEventStatsToEvacuationEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :evacuation_events, :typhoon_name, :string
    add_column :evacuation_events, :households_affected, :integer, default: 0, null: false
    add_column :evacuation_events, :residents_affected, :integer, default: 0, null: false
  end
end
