module Refinery
  module Blog
    class ItemsController < ::ApplicationController

      before_action :find_all_items
      before_action :find_page

      def index
        @filter_ids = {}
        [:section_id, :tmpl, :category_id, :tag_id].each do |key|
          @filter_ids[key] = params[key].present? ? params[key] : 'all'
          params.delete(key) if params[key].present? && params[key].to_s == 'all'
        end

        @items = @items.filter(@filter_ids)

        @filters = {}
        @filters[:section]  = Refinery::Blog::Section.find_by_slug(params[:section_id]) if params[:section_id].present?
        @filters[:tmpl]     = params[:tmpl]
        @filters[:category] = Refinery::Blog::Category.find(params[:category_id])       if params[:category_id].present?
        @filters[:tag]      = Refinery::Blog::Tag.find(params[:tag_id])                 if params[:tag_id].present?

        @popular_items = @items.popular.paginate(page: params[:page], :per_page => 6)
        @items = @items.paginate(page: params[:page], :per_page => 6)

        render params[:index_tmpl].presence || 'index'
      end

      def increment_view_count(item)
        return false unless item
        views_array = []

        if !(cookies[:blog_views] && (views_array = ActiveSupport::JSON.decode(cookies[:blog_views])).include?(item.master_uid))
          item.increment_view_count!
          views_array << item.master_uid
          cookies[:blog_views] = ActiveSupport::JSON.encode(views_array)
        end
      end

      def show
        begin
          @item = Item.published.friendly.find(params[:id])
          increment_view_count(@item)
          render @item.view_template
        rescue ActiveRecord::RecordNotFound => e
          if @item.blank? && (old_one = Item.was_published.friendly.find(params[:id])).present? && (cur_pub = old_one.published_version).present?
            @item.increment_view_count!
            redirect_to refinery.blog_item_path(cur_pub)
          else
            raise e
          end
        end
      end

    protected

      def find_all_items
        @items = Item.get_all
      end

      def find_page
        @page = ::Refinery::Page.where(:link_url => "/items").first
      end

    private

      def item_params
        params.require(:item).permit(:title, :body, :image, :view_template, :featured, :author_id, :content_type, :published_at)
      end

    end
  end
end
