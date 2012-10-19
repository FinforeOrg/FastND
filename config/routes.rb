FinforeWeb::Application.routes.draw do
  
  resources :users do 
    collection do
      get :forgot_password
      get :profiles
      post :contact_admin
    end
  end
  resources :user_sessions do
    collection do
      match  :create_network, :via => [:get, :post]
      match  :failure_network, :via => [:get, :post]
      match  :network_sign_in, :via => [:get, :post]
      match  :public_login, :via => [:get, :post]
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
      match :followers, :via => [:get, :post]
      match :friends, :via => [:get, :post]
      match :status_retweet, :via => [:get, :post]
      match :status_destroy, :via => [:get, :post]
      match :status_update, :via => [:get, :post]
      match :message_post, :via => [:get, :post]
      match :message_destroy, :via => [:get, :post]
      match :messages_sentbox, :via => [:get, :post]
      match :messages_inbox, :via => [:get, :post]
      match :home_timeline, :via => [:get, :post]
      match :mentions, :via => [:get, :post]
      match :search, :via => [:get, :post]
      match :friend_add, :via => [:get, :post]
      match :friend_remove, :via => [:get, :post]
      match :friends_pending, :via => [:get, :post]
      match :followers_pending, :via => [:get, :post]
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
      get  :delete_portfolio
      get  :delete_transaction
      match :agenda,           :via => [:get, :post]
      match :save_portfolio,   :via => [:get, :post]
      match :save_transaction, :via => [:get, :post]
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

end
