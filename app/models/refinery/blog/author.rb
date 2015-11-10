module Refinery
  module Blog
    class Author < Refinery::Core::BaseModel
      extend FriendlyId
      friendly_id :full_name, use: [:slugged, :finders]

      has_many :items
      belongs_to :photo, :class_name => '::Refinery::Image'

      # To enable admin searching, add acts_as_indexed on searchable fields, for example:
      #
      #   acts_as_indexed :fields => [:title]
      def full_name
        name = self.first_name + " " + self.last_name
        return name
      end

      class << self
        def get_all
          order('position ASC')
        end

      end
    end
  end
end
