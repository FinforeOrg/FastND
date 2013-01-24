require 'ostruct'
["finforenet","authlogic","twitter_oauth"].each do |folder|
  Dir[File.join(Rails.root, "lib", folder, "**", "*.rb")].sort.each { |lib| require(lib) }
end

require "#{Rails.root}/lib/portfolio_event.rb"
require "#{Rails.root}/lib/fgraph.rb"
require "#{Rails.root}/lib/oauth_media.rb"
#FinforeWeb::Application.middleware.use Oink::Middleware
