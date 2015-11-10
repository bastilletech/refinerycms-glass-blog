module Refinery
  module Blog
    class AuthorsController < ::ApplicationController

      before_action :find_all_authors
      before_action :find_page

      def index
        # you can use meta fields from your model instead (e.g. browser_title)
        # by swapping @page for @author in the line below:
        present(@page)
      end

      def show
        @author = Author.find(params[:id])

        # you can use meta fields from your model instead (e.g. browser_title)
        # by swapping @page for @author in the line below:
        present(@page)
      end

    protected

      def find_all_authors
        @authors = Author.order('position ASC')
      end

      def find_page
        @page = ::Refinery::Page.where(:link_url => "/authors").first
      end

    private

      def author_params
        params.require(:author).permit(:last_name, :first_name, :bio, :email, :twitter_url, :facebook_url, :photo)
      end

    end
  end
end
