require 'refinerycms-core'

module Refinery
  autoload :BlogGenerator, 'generators/refinery/blog_generator'

  module Blog
    require 'refinery/blog/engine'

    class << self
      attr_writer :root

      def root
        @root ||= Pathname.new(File.expand_path('../../../', __FILE__))
      end

      def factory_paths
        @factory_paths ||= [ root.join('spec', 'factories').to_s ]
      end
    end
  end
end
