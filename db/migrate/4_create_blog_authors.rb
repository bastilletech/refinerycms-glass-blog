class CreateBlogAuthors < ActiveRecord::Migration

  def up
    create_table :refinery_blog_authors do |t|
      t.string :last_name
      t.string :first_name
      t.text :bio
      t.string :email
      t.string :twitter_url
      t.string :facebook_url
      t.integer :photo_id
      t.integer :position
      
      t.timestamps
    end

    add_index ::Refinery::Blog::Author.table_name, :id


  end



  def down
    if defined?(::Refinery::Authentication::Devise::UserPlugin)
      ::Refinery::Authentication::Devise::UserPlugin.destroy_all({:name => "refinerycms-blog"})
    end

    if defined?(::Refinery::Page)
      ::Refinery::Page.delete_all({:link_url => "/blog/authors"})
    end

    drop_table :refinery_blog_authors

  end

end
