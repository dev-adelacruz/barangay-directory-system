# frozen_string_literal: true

class CreateResidents < ActiveRecord::Migration[7.1]
  def change
    create_table :residents do |t|
      t.references :household, null: false, foreign_key: true
      t.string :full_name, null: false
      t.integer :age
      t.integer :sex, default: 0, null: false
      t.string :relationship_to_head
      t.integer :special_needs_category, default: 0, null: false
      t.datetime :archived_at

      t.timestamps
    end

    add_index :residents, :special_needs_category
    add_index :residents, :archived_at
    add_index :residents, :full_name
  end
end
