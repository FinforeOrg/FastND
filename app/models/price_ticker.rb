class PriceTicker
  include Mongoid::Document
  
  field :ticker, :type => String
  field :position, :type => Integer
  index :ticker
  index :position

  default_scope asc(:position)
  
  belongs_to :feed_info, :index => true
end
