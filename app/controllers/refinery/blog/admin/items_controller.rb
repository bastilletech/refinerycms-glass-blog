require 'will_paginate/array'

module Refinery
  module Blog
    module Admin
      class ItemsController < ::Refinery::AdminController

        crudify :'refinery/blog/item',
                :conditions        => {:draft_status => 0}, # master_draft
                :search_conditions => {:draft_status => 0}, # master_draft
                :order => 'refinery_blog_items.created_at DESC', # drafts don't necessarily have a published_at yet
                :searchable => true,
                :sortable => false

        # NOTE: when making searchable: remember to add to your model `acts_as_indexed :fields => [:title, :body]`

        before_action :get_edit_lock, :only => [:edit]
        before_action :set_redirect_url, :only => [:edit]
        after_action  :set_video_url, :only => [:update]

        def get_edit_lock
          takeover_token = params[:takeover_token]
          takeover_token = @item.edit_token if current_refinery_user.id == @item.editor_id  # always allow take lock from self
          success = @item.get_edit_lock!(takeover_token, current_refinery_user)
          redirect_to refinery.editing_collision_blog_admin_item_path(@item) unless success
        end

        def set_redirect_url
          @redirect_path = refinery.articles_blog_admin_items_path
          @redirect_path = refinery.stories_blog_admin_items_path if @item.story?
          @redirect_path = refinery.resources_blog_admin_items_path if @item.resource?
        end

        def set_video_url
          @item.set_video_url_from_content
        end

        def editing_collision
          find_item()
        end

        def index
          @filters    = {}
          @filter_ids = {}
          @new_tmpl   = :article

          [:section_id, :tmpl, :category_id, :tag_id, :featured].each do |key|
            @filter_ids[key] = params[key].present? ? params[key] : 'all'
            params.delete(key) if params[key].present? && params[key].to_s == 'all'
          end

          if searching?
            search_all_items
          else
            find_all_items

            @items = @items.filter(@filter_ids)

            @filters[:section]  = Refinery::Blog::Section.find_by_slug(params[:section_id]) if params[:section_id].present?
            @filters[:tmpl]     = params[:tmpl]
            @filters[:category] = Refinery::Blog::Category.find(params[:category_id])       if params[:category_id].present?
            @filters[:tag]      = Refinery::Blog::Tag.find(params[:tag_id])                 if params[:tag_id].present?

            @new_tmpl = @filters[:tmpl]                                     if @filters[:tmpl].present?
            @new_tmpl = @items.section_default_template(@filters[:section]) if @filters[:section].present?
          end

          paginate_all_items

          respond_to do |format|
            format.html
          end
        end

        def new
          @item = Refinery::Blog::Item.new()
          @item.save(validate: false)
          @item.master_uid = @item.id
          @item.set_view_template(params[:tmpl])
          @item.save(validate: false)
          redirect_to refinery.edit_blog_admin_item_path(@item)
        end

        def update
          success, errors = @item.validate_edit_token(params[:item].delete(:edit_token))
          if !success
            render :editing_collision_modal, status: 409
            return
          end

          @item.assign_attributes(item_params)
          publish_it = /true|1/ === params[:publish]
          @item.slug = nil if publish_it
          @item.published_at = Date.current if publish_it && @item.published_at.blank?
          @item.tags.clear     if params[:item][:tag_ids].blank?
          @item.sections.clear if params[:item][:section_ids].blank?
          @item.set_default_section

          if @item.save(validate: publish_it)
            flash.notice = t(
              'refinery.crudify.updated',
              :what => "'\#{@item.title}'"
            )

            if !(/true|1/ === params[:autosave])
              @item.release_edit_lock!
            end

            create_or_update_successful
          else
            create_or_update_unsuccessful 'edit'
          end
        end

        def trash
          find_item
          @item.trash!
          render json: {message: 'successfully trashed it!'}, status: 200
        end

        def create_or_update_successful
          if /true|1/ === params[:publish]
            result = @item.publish
            logger.warn "Failed to create blog item" unless result
          end

          render json: {message: 'success!'}, status: 200
        end

        private

        # Only allow a trusted parameter "white list" through.
        def item_params
          params.require(:item).permit(:title, :body, :image_id, :view_template, :featured, :author_id, :content_type, :view_count, :slugify_title, :custom_slug, :published_at, :main_category_id, :featured_video_url, :category_ids => [], :section_ids => [], :tag_ids => [])
        end
      end
    end
  end
end
