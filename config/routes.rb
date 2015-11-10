Refinery::Core::Engine.routes.draw do

  # Frontend routes
  namespace :blog, :path => '' do
    resources :items, :path => 'content', :only => [:index, :show] do
      collection do
        get 'filter/:section_id(/:tmpl(/:category_id(/:tag_id)))',
            to: 'items#index', as: 'filter'
      end
    end
    resources :items, :path => '', :only => [] do
      collection do
        get 'blog',      to: 'items#index', as: 'articles',  defaults: { section_id: 'blog',      index_tmpl: 'blog_index' }
        get 'resources', to: 'items#index', as: 'resources', defaults: { section_id: 'resources', index_tmpl: 'resource_index' }
        get 'stories',   to: 'items#index', as: 'stories',   defaults: { tmpl:       'story',     index_tmpl: 'story_index' }
      end
    end
    resources :authors, :only => [:index, :show]
  end

  # Admin routes
  namespace :blog, :path => '' do
    namespace :admin, :path => Refinery::Core.backend_route do
      resources :items, :path => 'blog', :except => :show do
        member do
          get :editing_collision
          delete :trash, as: 'trash'
        end
        collection do
          get 'new/:tmpl', to: 'items#new', as: 'new_tmpl'
          get 'articles',  to: 'items#index', as: 'articles',  defaults: { section_id: 'blog' }
          get 'resources', to: 'items#index', as: 'resources', defaults: { section_id: 'resources' }
          get 'stories',   to: 'items#index', as: 'stories',   defaults: { tmpl: 'story' }
          get 'filter/:section_id(/:tmpl(/:category_id(/:tag_id(/:featured))))',
              to: 'items#index', as: 'filter'
        end
      end
    end
    namespace :admin, :path => "#{Refinery::Core.backend_route}/blog" do
      resources :authors, :except => :show do
        collection do
          post :update_positions
        end
      end
      resources :sections, :except => :show do
        collection do
          post :update_positions
        end
      end
      resources :categories, :except => :show do
        collection do
          post :update_positions
        end
      end
      resources :tags, :except => :show
    end
  end
end
