class CreateBlogSections < ActiveRecord::Migration

  def up
    create_table :refinery_blog_sections do |t|
      t.string :slug
      t.integer :position
      
      t.timestamps
    end

    add_index ::Refinery::Blog::Section.table_name, :id


  end



  def down
    if defined?(::Refinery::Authentication::Devise::UserPlugin)
      ::Refinery::Authentication::Devise::UserPlugin.destroy_all({:name => "refinerycms-blog"})
    end

    if defined?(::Refinery::Page)
      ::Refinery::Page.delete_all({:link_url => "/blog/sections"})
    end

    drop_table :refinery_blog_sections

  end

end
