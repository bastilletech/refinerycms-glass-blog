class AddMainCategoryAndCategoryImage < ActiveRecord::Migration
  def change
    add_column :refinery_blog_items, :main_category_id, :integer
    add_column :refinery_blog_categories, :image_id, :integer
  end
end
