require 'will_paginate/array'

module Refinery
  module Blog
    module Admin
      class SectionsController < ::Refinery::AdminController

        crudify :'refinery/blog/section',
                :title_attribute => 'slug',
                :searchable => false,
                :sortable => false

        # NOTE: when making searchable: remember to add to your model `acts_as_indexed :fields => [:title, :body]`

        def index
          unless searching?
            find_all_sections
          else
            search_all_sections
          end

          @grouped_sections = group_by_date(@sections)

          @sections = @sections.paginate(page: params[:page])

          respond_to do |format|
            format.html
          end
        end

        private

        # Only allow a trusted parameter "white list" through.
        def section_params
          params.require(:section).permit(:slug)
        end


        # NOTE: This can be moved back into crudify (that's where it came from)
        # Returns a weighted set of results based on the query specified by the user.
        def search_all_sections
          # First find normal results.
          find_all_sections('')

          # Now get weighted results by running the query against the results already found.
          @sections = @sections.with_query('^' + params[:search].split.join(' ^'))
        end
      end
    end
  end
end
