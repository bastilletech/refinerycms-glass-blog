module Refinery
  module Blog
    class Section < Refinery::Core::BaseModel

      has_and_belongs_to_many :items, :join_table => :refinery_item_sections

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
