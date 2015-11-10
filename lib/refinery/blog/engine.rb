module Refinery
  module Blog
    class Engine < Rails::Engine
      extend Refinery::Engine
      isolate_namespace Refinery::Blog

      engine_name :refinery_blog

      before_inclusion do
        Refinery::Plugin.register do |plugin|
          plugin.name = "blog"
          plugin.url = proc { Refinery::Core::Engine.routes.url_helpers.articles_blog_admin_items_path }
          plugin.pathname = root
          plugin.menu_match = %r{refinery/blog(/.*)?$}
          plugin.position = 6
          plugin.icon = 'icon icon-feather'
        end

        Refinery::Plugin.register do |plugin|
          plugin.name = "stories"
          plugin.url = proc { Refinery::Core::Engine.routes.url_helpers.stories_blog_admin_items_path }
          plugin.pathname = root
          plugin.menu_match = %r{refinery/blog/stories(/.*)?$}
          plugin.position = 7
          plugin.icon = 'icon icon-user icon-fe'
        end

        Refinery::Plugin.register do |plugin|
          plugin.name = "resources"
          plugin.url = proc { Refinery::Core::Engine.routes.url_helpers.resources_blog_admin_items_path }
          plugin.pathname = root
          plugin.menu_match = %r{refinery/blog/resources(/.*)?$}
          plugin.position = 8
          plugin.icon = 'icon icon-book icon-fe'
        end
      end

      config.after_initialize do
        Refinery.register_extension(Refinery::Blog)
      end
    end
  end
end
