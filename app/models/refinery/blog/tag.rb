module Refinery
  module Blog
    class Tag < Refinery::Core::BaseModel
      extend FriendlyId
      friendly_id :title, use: [:slugged, :finders]

      validates :title, :presence => true, :uniqueness => true

      has_and_belongs_to_many :items, :join_table => :refinery_item_tags

      # To enable admin searching, add acts_as_indexed on searchable fields, for example:
      #
      #   acts_as_indexed :fields => [:title]

      class << self
        def to_hash
          h = {}
          self.all.each do |tag|
            h[tag.id] = {title: tag.title}
          end
          return h
        end

        def find_duplicate(tag_data)
          new_slug = Refinery::Blog::Tag.new().normalize_friendly_id(tag_data[:title])
          begin
            return Refinery::Blog::Tag.friendly.find(new_slug)
          rescue ActiveRecord::RecordNotFound => e
            return nil
          end
        end

        def get_all
          order('position ASC')
        end

      end
    end
  end
end
