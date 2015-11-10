class AddMetaToTag < ActiveRecord::Migration
  def change
    add_column :refinery_blog_tags, :meta, :string
  end
end
