class CompanyCompetitor
  include Mongoid::Document
  
  field :keyword,           :type => String
  field :competitor_ticker, :type => String
  field :company_keyword,   :type => String
  field :broadcast_keyword, :type => String
  field :finance_keyword,   :type => String
  field :bing_keyword,      :type => String
  field :blog_keyword,      :type => String
  field :company_ticker,    :type => String
  
  belongs_to :feed_info, :index => true
end

# twitter_path = "#{Rails.root}/twitter.csv"
# company_path = "#{Rails.root}/company.csv"
# twitter_csv = [["Title", "Address", "Geographic", "Industry", "Profession"]]
# company_csv = [["Title", "Geographic", "Industry", "Profession", "Ticker", "Keyword", "Competitor Ticker", "Competitor Keyword", "Broadcast Keyword", "Finance Keyword", "Bing Keyword", "Blog Keyword"]]
# #CSV.open(filename, 'w') do |csv| 
# csv_data = CSV.new(File.read("#{Rails.root}/co_code.csv"))
# csv_data.shift
# csv_data.each do |row|
#   twitter_csv.push([row[0],row[1],row[2],row[3],""])
#   company_csv.push([row[0], row[2], row[3], "", row[4], "#{row[4]},\"#{row[0]}\"", row[5].split(/\s/).join(","), row[6].split(/\s/).join(","), row[0], row[4], "#{row[4]},#{row[0]}", "#{row[4]},#{row[0]}"])
# end

# CSV.open(twitter_path, 'w') do |csv| 
#   twitter_csv.each do |tc|
#     csv << tc
#   end
# end
# CSV.open(company_path, 'w') do |csv| 
#   company_csv.each do |cc|
#     csv << cc
#   end
# end
