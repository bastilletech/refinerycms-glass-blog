class AddFeaturedVidToBlogItem < ActiveRecord::Migration
  def change
    add_column :refinery_blog_items, :featured_video_url, :string
  end
end
