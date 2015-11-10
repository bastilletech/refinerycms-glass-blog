class AddSlugsToCategoriesTagsAndAuthors < ActiveRecord::Migration
  def change
    add_column :refinery_blog_tags, :slug, :string
    add_column :refinery_blog_categories, :slug, :string
    add_column :refinery_blog_authors, :slug, :string
  end
end
