module Refinery
  module Blog
    class Category < Refinery::Core::BaseModel
      extend FriendlyId
      friendly_id :title, use: [:slugged, :finders]

      has_and_belongs_to_many :items, :join_table => :refinery_item_categories
      belongs_to :image, :class_name => '::Refinery::Image'

      # To enable admin searching, add acts_as_indexed on searchable fields, for example:
      #
      #   acts_as_indexed :fields => [:title]

      class << self
        def get_all
          order('position ASC')
        end

      end
    end
  end
end
