FinforeWeb::Application.routes.draw do
  
  resources :users do 
    collection do
      get :forgot_password
      get :profiles
      get :contact_admin
    end
  end
  resources :user_sessions do
    collection do
      get  :create_network
      post :create_network
      get  :failure_network
      post :failure_network
      get  :network_sign_in
      post :network_sign_in
      get  :public_login
      post :public_login
    end
  end
  
  resources :feed_accounts do
	collection do 
	  get :column_auth 
	  get :column_callback
	end
  end
  
  resources :tweetfores do
	collection do
      get :followers
      get :friends
      get :status_retweet
      get :status_destroy
      get :status_update
      get :message_post
      get :message_destroy
      get :messages_sentbox
      get :messages_inbox
      get :home_timeline
      get :mentions
      get :search
      get :friend_add
      get :friend_remove
      get :friends_pending
      get :followers_pending
      post :followers
      post :friends
      post :status_retweet
      post :status_destroy
      post :status_update
      post :message_post
      post :message_destroy
      post :messages_sentbox
      post :messages_inbox
      post :home_timeline
      post :mentions
      post :search
      post :friend_add
      post :friend_remove
      post :friends_pending
      post :followers_pending
	end
  end
  
  resources :linkedins do 
	collection do 
	  get :authenticate
      get :network_status
      get :callback
	end
  end
  
  resources :facebookers do
	collection do
      get :my
      get :publish
      get :search
	end
  end
  
  resources :portfolios do
    collection do
      get  :overviews
      get  :transactions
      get  :positions
      get  :list
      get  :agenda
	  post :agenda 
	  get  :save_portfolio
      post :save_portfolio
      get  :delete_portfolio
	  post :save_transaction
      get  :save_transaction
      get  :delete_transaction
	end
  end
  
  resources :user_feeds
  resources :keyword_columns
  resources :feed_apis
  resources :user_company_tabs
  resources :feed_infos
  
  match '/client/login'             => 'user_sessions#new'
  match '/logout'                   => 'user_sessions#destroy'
  match 'auth/:provider'            => 'user_sessions#network_sign_in'
  match '/auth/:provider/callback'  => 'user_sessions#create_network'
  match '/auth/failure'             => 'user_sessions#failure_network'
  match "/feed_accounts/:provider/auth", :controller => "feed_accounts", :action => "column_auth"
  match "/feed_accounts/:provider/callback", :controller => "feed_accounts", :action => "column_callback"
  match "/my/:category.:format", :controller => "facebookers", :action=> "my"
  match "/:pid/publish/:pubtype.:format", :controller => "facebookers", :action=> "publish"
  match "/search/:type.:format", :controller => "facebookers", :action=> "publish"
  match "/category_focus.:format",:controller => "users", :action => "profiles"

  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
