# Module Extention for user_feed.rb
# Additional Modules/Gems: mongoid_followable
# The extention includes:
#   * Authorize user to have ability to follow or followed
#   * Generate autopopulate from feed_info
module Finforenet
  module Models
    module ExtUser
      extend ActiveSupport::Concern
      
      included do
        include Finforenet::Models::Authenticable
        include Finforenet::Models::SharedQuery
        include Finforenet::Models::Jsonable
        include Mongoid::Followable
        include Mongoid::Follower

        field :_profile_ids, type: Array
      end

      def create_autopopulate
        current_profile_ids = self.user_profiles.map(&:profile_id)
        countries, sectors, professions = [], [], []
        current_profile_ids.each do |profile_id|
          next if profile_id.blank?
          profile = Profile.find(profile_id)
          if profile
            if profile.profile_category.title =~ /geo/i
              countries.push(profile_id)
            elsif profile.profile_category.title =~ /ind/i
              sectors.push(profile_id)
            elsif profile.profile_category.title =~ /pro/i
              professions.push(profile_id)
            end
          end
        end

         populate_company_tabs(countries, sectors, professions)
         populate_rss(countries, sectors, professions)
         populate_prices(countries, sectors, professions)
         populate_podcast(countries, sectors, professions)
         self.update_attribute(:has_populated, true)
      end

      def populate_prices(countries, sectors, professions)
        results = populated_resources(countries, sectors, professions, "price", 3)
        results.each do |result|
          self.feed_accounts.create({name: result.title, 
                                     category: "chart",
                                      user_feeds_attributes: [
                                        {title: result.title, feed_info_id: result.id}
                                      ]
                                    })
        end
      end

      def populate_rss(countries, sectors, professions)
        results = populated_resources(countries, sectors, professions, "rss", nil)
        user_feeds_attributes = []
        results.each do |result|
          user_feeds_attributes.push( {title: result.title, feed_info_id: result.id} )
        end
        diff = (user_feeds_attributes.count/2).to_i
        self.feed_accounts.create({name: "Latest News", 
                                   category: "rss",
                                   user_feeds_attributes: user_feeds_attributes[0..(diff-1)]
                                 })
        self.feed_accounts.create({name: "Latest News", 
                                   category: "rss",
                                   user_feeds_attributes: user_feeds_attributes[diff..(user_feeds_attributes.count-1)]
                                 })
      end

      def populate_podcast(countries, sectors, professions)
        results = populated_resources(countries, sectors, professions, "podcast", nil)
        user_feeds_attributes = []
        results.each do |result|
          user_feeds_attributes.push( {title: result.title, feed_info_id: result.id} )
        end
        self.feed_accounts.create({name: "Podcasts", 
                                   category: "podcast",
                                   user_feeds_attributes: user_feeds_attributes
                                 })
        
      end

      def populate_company_tabs(countries, sectors, professions)
        results = populated_resources(countries, sectors, professions, "company", 5)
        results.each do |result|
          self.user_company_tabs.find_or_create_by({follower: 100, is_aggregate: false, feed_info_id: result.id})
        end
      end

      def populated_resources(countries, sectors, professions, category, limit)
        populations = SourcePopulation.where({category: category, 
                                              :country_ids.in => countries, 
                                              :sector_ids.in => sectors, 
                                              :profession_ids.in => professions
                                            })
        source_ids = populations.map{|population| population.sources}.flatten.compact.uniq
        result = FeedInfo.where({:_id.in => source_ids}).desc(:votes).limit(limit)
        return result unless limit
        result.limit(limit)
      end

    end
  end
end
