class AddAutosaveFieldsToItems < ActiveRecord::Migration
  def change
    add_column :refinery_blog_items, :master_uid, :integer
    add_column :refinery_blog_items, :draft_status,     :integer, :default => 0
    add_column :refinery_blog_items, :draft_status_int, :integer, :default => 0
    add_column :refinery_blog_items, :edit_token, :string
    add_column :refinery_blog_items, :editor_id, :integer
  end
end
