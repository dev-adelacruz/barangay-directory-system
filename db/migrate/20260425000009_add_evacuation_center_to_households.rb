# frozen_string_literal: true

class AddEvacuationCenterToHouseholds < ActiveRecord::Migration[7.1]
  def change
    add_reference :households, :evacuation_center, null: true, foreign_key: true
  end
end
