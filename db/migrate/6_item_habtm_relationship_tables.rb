class ItemHabtmRelationshipTables < ActiveRecord::Migration
  def change
    create_table :refinery_item_categories, :id => false do |t|
      t.integer :item_id
      t.integer :category_id
    end

    create_table :refinery_item_sections, :id => false do |t|
      t.integer :item_id
      t.integer :section_id
    end

    create_table :refinery_item_tags, :id => false do |t|
      t.integer :item_id
      t.integer :tag_id
    end
  end
end
