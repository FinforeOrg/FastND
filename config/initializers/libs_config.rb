require 'ostruct'
["finforenet","authlogic"].each do |folder|
  Dir[File.join(Rails.root, "lib", folder, "**", "*.rb")].sort.each { |lib| require(lib) }
end

require "#{Rails.root}/lib/fgraph.rb"
FinforeWeb::Application.middleware.use Oink::Middleware
