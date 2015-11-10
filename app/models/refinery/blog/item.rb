require 'securerandom'

module Refinery
  module Blog
    class Item < Refinery::Core::BaseModel
      extend FriendlyId
      friendly_id :title, use: [:slugged, :finders, :scoped], :scope => :draft_status_int

      belongs_to :image, :class_name => '::Refinery::Image'
      belongs_to :editor, :class_name => Refinery::Authentication::Devise::User
      belongs_to :author

      has_and_belongs_to_many :categories, :join_table => :refinery_item_categories
      has_and_belongs_to_many :sections,   :join_table => :refinery_item_sections
      has_and_belongs_to_many :tags,       :join_table => :refinery_item_tags

      belongs_to :main_category, :class_name => Refinery::Blog::Category

      enum draft_status: [ :master_draft, :draft, :published, :was_published ]
      enum content_type: [ :text, :video, :image ]
      enum view_template: [ :article, :resource, :story ]

      scope :in_section,    ->(section_id) { joins(:sections).where(refinery_blog_sections:     { slug: section_id             }) }
      scope :with_template, ->(tmpl)       { where(:view_template => view_templates[tmpl]) }
      scope :in_category,   ->(cat_id)     { joins(:categories).where(refinery_blog_categories: { id: Category.find(cat_id).id }) }
      scope :with_tag,      ->(tag_id)     { joins(:tags).where(refinery_blog_tags:             { id: Tag.find(tag_id).id      }) }
      scope :in_categories, ->(cat_ids)    { joins(:categories).where('refinery_blog_categories.id IN (?)', cat_ids) }

      scope :filter, ->(filter_ids) {
        items = self
        items = items.in_section(filter_ids[:section_id])   if filter_ids[:section_id].present?  && filter_ids[:section_id]  != 'all'
        items = items.with_template(filter_ids[:tmpl])      if filter_ids[:tmpl].present?        && filter_ids[:tmpl]        != 'all'
        items = items.in_category(filter_ids[:category_id]) if filter_ids[:category_id].present? && filter_ids[:category_id] != 'all'
        items = items.with_tag(filter_ids[:tag_id])         if filter_ids[:tag_id].present?      && filter_ids[:tag_id]      != 'all'
        items = items.featured.reorder('published_at DESC').limit(15) if filter_ids[:featured].present? && filter_ids[:featured] != 'all'
        return items
      }

      scope :featured, -> { where(:featured => true).limit(5) }
      scope :popular,  -> { reorder('view_count DESC') }

      FIXED_TMPL_SECTIONS = {
        :article  => :blog,
        :resource => :resources
      }

      validates :title, :presence => true
      validates :main_category, :presence => true
      validates :image, :presence => true

      acts_as_indexed :fields => [:title, :body]

      before_validation :save_draft_status_for_friendly_id, prepend: true

      def get_edit_lock!(takeover_token, editor)
        if self.edit_token.present? && self.edit_token != takeover_token && (self.updated_at > 15.minutes.ago)
          return false
        end

        self.edit_token = SecureRandom.uuid
        self.editor = editor
        self.save(validate: false)
      end

      def release_edit_lock!
        self.edit_token = nil
        self.save(validate: false)
      end

      def validate_edit_token(their_token)
        return (self.edit_token.present? && self.edit_token === their_token), "Someone else is currently editing"
      end

      def save_draft_status_for_friendly_id
        self.draft_status_int = self.read_attribute(:draft_status)
      end

      def increment_view_count!
        self.increment!(:view_count)
      end

      def publish
        cur_pub = self.published_version
        if cur_pub.present?
          cur_pub.slug = nil
          # ensure there is a main_category or validation will fail here (only old items may not have main_category set)
          cur_pub.main_category = Refinery::Blog::Category.first() unless cur_pub.main_category.present?
          cur_pub.was_published! # this saves as well
        end

        pub_copy = self.clone_new_published_version(cur_pub)
        pub_copy.published! # this saves as well

        return true
      end

      def trash!
        all_versions = self.class.where(:master_uid => self.master_uid)

        if self.unpublished?
          all_versions.master_draft.each do |item|
            item.draft!
          end
        end

        all_versions.published.each do |item|
          item.was_published!
        end
      end

      def set_default_section
        section = Section.find_by_slug(self.default_section_slug)
        if section.present? && !self.sections.exists?(section.id)
          self.sections << section
        end
      end

      def default_section_slug
        return FIXED_TMPL_SECTIONS[self.view_template.to_sym]
      end

      def non_default_sections_except(section)
        result_sections = []
        default_section = FIXED_TMPL_SECTIONS[self.view_template.to_sym]

        self.sections.each do |s|
          if !(section.present? && s.slug == section.slug) &&
             !(default_section.present? && s.slug == default_section.to_s)
            result_sections << s
          end
        end

        return result_sections
      end

      def template_not_in(section, tmpl)
        if section.present? && self.class.section_default_template(section).to_s == self.view_template
          return false
        end

        return !(tmpl.present? && tmpl.to_s == self.view_template)
      end

      def unpublished?
        return self.published_version.blank?
      end

      def published_version
        return Item.published.where(:master_uid => self.master_uid).last
      end

      def clone_new_published_version(current_published_version)
        # copy most attributes from master_draft (self)
        new_pub = self.dup

        # copy rest of the attributes from master_draft (self)
        new_pub.categories = self.categories
        new_pub.sections   = self.sections
        new_pub.tags       = self.tags

        # copy over attributes from the current published version
        if current_published_version.present?
          new_pub.view_count = current_published_version.view_count
          current_published_version.view_count = 0
          current_published_version.save
        end

        return new_pub
      end

      def related
        self.class.get_all
          .with_template(self.view_template.to_sym)
          .in_categories(self.categories.map(&:id))
          .where('refinery_blog_items.id != ?', self.id)
      end

      def set_view_template(tmpl_symbol)
        self.view_template = tmpl_symbol.present? ? self.class.view_templates[tmpl_symbol] : 0
      end

      def set_video_url_from_content
        if self.featured_video_url.present?
          url = self.featured_video_url
        else
          # search to see if there is a youtube video in the html content for the article
          url = self.body[/\s*(www.youtube(?:-nocookie)?.com\/(?:v|embed)\/([a-zA-Z0-9\-_]+)).*/,1]
          url.sub!('embed', 'v') if url.present?
          url.sub!('watch', 'v') if url.present?
          url = self.body[/\s*(player.vimeo?.com\/(video)\/([0-9]+)).*/, 1] if url.blank?
        end

        if self.video_url != url
          self.video_url = url
          self.save(validate: false)
        end
      end

      def content_type
        return self.video_url.present? ? 'video' : ''
      end

      def author_photo_url(geometry)
        return author.present? && author.photo.present? ?
          author.photo.thumbnail(:geometry => geometry).url :
          '/assets/anonymous.jpg'
      end

      def category_title
        return self.main_category.present? ? self.main_category.title : 'To be Categorized'
      end

      def image_url(geometry)
        return image.present? ? image.thumbnail(geometry: geometry).url : "/assets/cover.jpg"
      end

      def format_published_at
        return published_at.present? ? published_at.strftime("%B %e, %Y") : 'Draft'
      end

      def format_view_count
        return ActionController::Base.helpers.number_with_delimiter(self.view_count, :delimiter => ',')
      end

      class << self
        def get_all
          published.where('published_at < ?', DateTime.current).order('published_at DESC')
        end

        def section_default_template(section)
          return section.slug == 'resources' ? :resource : :article
        end

        def index_title(section, tmpl)
          section.present? ? section.slug.capitalize : (tmpl.present? ? tmpl.to_s.capitalize.pluralize : "Blog")
        end
      end
    end
  end
end
