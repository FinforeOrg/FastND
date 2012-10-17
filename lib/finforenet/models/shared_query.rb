module Finforenet
  module Models 
    module SharedQuery
      extend ActiveSupport::Concern
      
      included do
	      include InstancesMethods
      end

      module InstancesMethods
		
		    def updated_position
			    _record = self.class.all.desc(:position).first
			    _record ? (_record.position.to_i + 1) : 0
				end
	  
      end
      
      module ClassMethods
		    def rss_query(options = {})
		    	options["$and"] = [{:address=> REGEX_HTTP}, {:address=>{"$not"=> REGEX_MULTIMEDIA}}]
		    	options[:category] = Regexp.new('rss',Regexp::IGNORECASE)
		    	return options
		    end
		    
		    def company_query(options={})
		    	single_ticker = {"$and" => [{:address => /^\W/i}, {:address => {"$not" => /\s+/}} ] }
		    	options.merge!({"$or" => [{:category => REGEX_COMPANY}, single_ticker ]})
		    	options.merge!({:address=> {"$not" => REGEX_HTTP}, :category => {"$not" => /chart/i} })
		    	return options
		    end

		def relevant_query(user, category)
		  user_profiles = user._profile_ids
                  relevant_ids = []
                  category = "chart|price" if category =~ /chart|price/i
                  conditions = {category: /#{category}/i}
                  user_profiles.each do |up|
                    profile = Profile.find(up)
                    conditions.merge!({profile_category_id: profile.profile_category_id, profile_id: up})
                    if relevant_ids.present?
                      conditions.merge!({:feed_info_id.in => relevant_ids})
                    end
                    tmp_relevant_ids = FeedInfo::Profile.where(conditions).distinct(:feed_info_id)
                    relevant_ids = tmp_relevant_ids if tmp_relevant_ids.present?
		  end
                  return {:_id =>  {"$in" =>relevant_ids}}
                end

		    def twitter_query(options = {})
		    	options.merge!({:category => /twitter/i, :address => {"$not" => REGEX_HTTP}})
		    	return options
		    end
		    
		    def all_companies_query(options={})
		    	return company_query(options)
		    end
		    
		    def populated_query(options = {})
		    	options[:is_populate] = true
		    	return options
		    end
		    
		    def profiles_query(user, options = {})
		    	profile_ids = user.user_profiles.map(&:profile_id)
		    	feed_info_ids = FeedInfo::Profile.where(:profile_id.in => profile_ids).map(&:feed_info_id)
		    	options[:_id] = {"$in" => feed_info_ids} unless feed_info_ids.size < 1
		    	return options
		    end
		    
		    def podcast_query(options={})
		    	options.merge!({:category => /podcast/i, 
			    	             "$and" => [{:address => REGEX_HTTP}, 
				    	                      {:address => {"$not" => /youtube/i}}
				    	                     ]
				    	          })
		    	return options
		    end
		    
		    def chart_query(options={})
		    	options.merge!({:category => /chart|price/i, :title => /\w|\W/i})
		    end  
      end
      
    end
  end
end
