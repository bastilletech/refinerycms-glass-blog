require 'will_paginate/array'

module Refinery
  module Blog
    module Admin
      class TagsController < ::Refinery::AdminController

        crudify :'refinery/blog/tag',
                :searchable => false,
                :sortable => false

        # NOTE: when making searchable: remember to add to your model `acts_as_indexed :fields => [:title, :body]`

        before_action :find_duplicate, :only => [:create]

        def index
          unless searching?
            find_all_tags
          else
            search_all_tags
          end

          @grouped_tags = group_by_date(@tags)

          @tags = @tags.paginate(page: params[:page])

          respond_to do |format|
            format.html
          end
        end

        def find_duplicate
          @duplicate = Refinery::Blog::Tag.find_duplicate(params[:tag])

          if @duplicate.present?
            @tag = @duplicate
            create_or_update_successful
            return false
          end
        end

        def create_or_update_successful
          render json: {message: 'success!', tag_id: @tag.id, tag_title: @tag.title}, status: 200
        end

        def create_or_update_unsuccessful(action)
          render json: {errors: @tag.errors.full_messages}, status: 400
        end

        private

        # Only allow a trusted parameter "white list" through.
        def tag_params
          params.require(:tag).permit(:title, :meta)
        end


        # NOTE: This can be moved back into crudify (that's where it came from)
        # Returns a weighted set of results based on the query specified by the user.
        def search_all_tags
          # First find normal results.
          find_all_tags('')

          # Now get weighted results by running the query against the results already found.
          @tags = @tags.with_query('^' + params[:search].split.join(' ^'))
        end
      end
    end
  end
end
