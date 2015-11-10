require 'will_paginate/array'

module Refinery
  module Blog
    module Admin
      class CategoriesController < ::Refinery::AdminController

        crudify :'refinery/blog/category',
                :searchable => false,
                :sortable => false

        # NOTE: when making searchable: remember to add to your model `acts_as_indexed :fields => [:title, :body]`

        def index
          unless searching?
            find_all_categories
          else
            search_all_categories
          end

          @grouped_categories = group_by_date(@categories)

          @categories = @categories.paginate(page: params[:page])

          respond_to do |format|
            format.html
          end
        end

        private

        # Only allow a trusted parameter "white list" through.
        def category_params
          params.require(:category).permit(:title, :image_id)
        end


        # NOTE: This can be moved back into crudify (that's where it came from)
        # Returns a weighted set of results based on the query specified by the user.
        def search_all_categories
          # First find normal results.
          find_all_categories('')

          # Now get weighted results by running the query against the results already found.
          @categories = @categories.with_query('^' + params[:search].split.join(' ^'))
        end
      end
    end
  end
end
