require 'will_paginate/array'

module Refinery
  module Blog
    module Admin
      class AuthorsController < ::Refinery::AdminController

        crudify :'refinery/blog/author',
                :title_attribute => 'last_name',
                :searchable => false,
                :sortable => false

        # NOTE: when making searchable: remember to add to your model `acts_as_indexed :fields => [:title, :body]`

        def index
          unless searching?
            find_all_authors
          else
            search_all_authors
          end

          @grouped_authors = group_by_date(@authors)

          @authors = @authors.paginate(page: params[:page])

          respond_to do |format|
            format.html
          end
        end

        private

        # Only allow a trusted parameter "white list" through.
        def author_params
          params.require(:author).permit(:last_name, :first_name, :bio, :email, :twitter_url, :facebook_url, :photo_id)
        end


        # NOTE: This can be moved back into crudify (that's where it came from)
        # Returns a weighted set of results based on the query specified by the user.
        def search_all_authors
          # First find normal results.
          find_all_authors('')

          # Now get weighted results by running the query against the results already found.
          @authors = @authors.with_query('^' + params[:search].split.join(' ^'))
        end
      end
    end
  end
end
