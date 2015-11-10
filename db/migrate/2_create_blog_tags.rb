class CreateBlogTags < ActiveRecord::Migration

  def up
    create_table :refinery_blog_tags do |t|
      t.string :title
      t.integer :position
      
      t.timestamps
    end

    add_index ::Refinery::Blog::Tag.table_name, :id


  end



  def down
    if defined?(::Refinery::Authentication::Devise::UserPlugin)
      ::Refinery::Authentication::Devise::UserPlugin.destroy_all({:name => "refinerycms-blog"})
    end

    if defined?(::Refinery::Page)
      ::Refinery::Page.delete_all({:link_url => "/blog/tags"})
    end

    drop_table :refinery_blog_tags

  end

end
