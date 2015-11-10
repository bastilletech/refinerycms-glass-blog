module Refinery
  module Blog
    class SectionsController < ::ApplicationController

      before_action :find_all_sections
      before_action :find_page

      def index
        # you can use meta fields from your model instead (e.g. browser_title)
        # by swapping @page for @section in the line below:
        present(@page)
      end

      def show
        @section = Section.find(params[:id])

        # you can use meta fields from your model instead (e.g. browser_title)
        # by swapping @page for @section in the line below:
        present(@page)
      end

    protected

      def find_all_sections
        @sections = Section.order('position ASC')
      end

      def find_page
        @page = ::Refinery::Page.where(:link_url => "/sections").first
      end

    private

      def section_params
        params.require(:section).permit(:slug)
      end

    end
  end
end
