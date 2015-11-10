class CreateBlogItems < ActiveRecord::Migration

  def up
    create_table :refinery_blog_items do |t|
      t.string   :title
      t.text     :body
      t.integer  :image_id
      t.integer  :view_template, :default => 0
      t.boolean  :featured,      :default => false
      t.integer  :author_id
      t.integer  :content_type,  :default => 0
      t.integer  :view_count,    :default => 0
      t.datetime :published_at
      t.integer  :position

      t.string   :slug
      t.string   :video_url

      t.timestamps
    end

    add_index ::Refinery::Blog::Item.table_name, :id


  end



  def down
    if defined?(::Refinery::Authentication::Devise::UserPlugin)
      ::Refinery::Authentication::Devise::UserPlugin.destroy_all({:name => "refinerycms-blog"})
    end

    if defined?(::Refinery::Page)
      ::Refinery::Page.delete_all({:link_url => "/blog/items"})
    end

    drop_table :refinery_blog_items

  end

end
