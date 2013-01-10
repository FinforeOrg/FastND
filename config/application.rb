require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
#require "sprockets/railtie"
require "rails/test_unit/railtie"

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
  #Bundler.require(:default, Rails.env)
end

module FinforeWeb
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation, :auth_token, :auth_session, :auth_secret, :id]

    # Enable the asset pipeline
    config.assets.enabled = false

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    config.filter_parameters << :password << :password_confirmation

    config.middleware.use "::ExceptionNotifier",
      :email_prefix => "[FinforeNet Error] ",
      :sender_address => %{info@finfore.net},
      :exception_recipients => %w{yacobus.reinhart@gmail.com}

    config.generators do |g|
      g.test_framework :rspec, :views => false, :fixture => true
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
    end
    
    # turn on autoloading of lib directory and all its subdirectories
#    config.autoload_paths += %W(#{config.root}/lib)
#    config.autoload_paths += Dir["#{config.root}/lib/**/"]    
    config.middleware.use Rack::Mongoid::Middleware::IdentityMap
    config.middleware.use Rack::Cors do |cor|
      cor.allow do |allow|
        allow.origins "*"
        allow.resource "/*", :methods => [:get, :post, :put, :delete, :options]
        allow.resource "/users/*", :methods => [:get, :post, :put, :delete, :options]
        allow.resource "/user_sessions/*", :methods => [:get, :post, :put, :delete, :options]
        allow.resource "/feed_accounts/*", :methods => [:get, :post, :put, :delete, :options]
        allow.resource "/tweetfores/*", :methods => [:get, :post, :options]
        allow.resource "/linkedins/*", :methods => [:get, :post, :options]
        allow.resource "/facebookers/*", :methods => [:get, :post, :options]
        allow.resource "/user_feeds/*", :methods => [:get, :post, :put, :delete, :options]
        allow.resource "/keyword_columns/*", :methods => [:get, :post, :put, :delete, :options]
        allow.resource "/feed_apis/*", :methods => [:get, :post, :put, :delete, :options]
        allow.resource "/user_company_tabs/*", :methods => [:get, :post, :put, :delete, :options]
        allow.resource "/feed_infos/*", :methods => [:get, :post, :put, :delete, :options]
      end
    end
    
  end
end
