class FeedInfosController < ApplicationController
  before_filter :prepare_condition, :only => [:index]
  caches_action :index, :cache_path => Proc.new { |controller| controller.params }, :expires_in => 4.hours
  
  def index  
    prepare_list_for_user if current_user
	@feed_infos = Kaminari.paginate_array(@feed_infos).page(params[:page]||1).per(params[:per_page]||25) unless is_chart_or_all_companies
    respond_to do |format|
      respond_to_do(format, @feed_infos)
    end
  end

  private 
    
    def prepare_condition
      @feed_infos = []
      @show_all = is_show_all
      @conditions = FeedInfo.send("#{@category}_query")
      @conditions = FeedInfo.profiles_query(current_user,@conditions) if profileable?
    end

    def profileable?
      current_user && !@show_all && !is_chart
    end

    def prepare_list_for_user
      if !is_chart_or_all_companies
        @feed_infos = FeedInfo.filter_feeds_data(@conditions,(params[:per_page]||25), params[:page]||1)
		sanitize_feed_info_profile unless @show_all
      elsif is_all_companies
        #@feed_infos = FeedInfo.all_with_competitor(@conditions)
         @feed_infos = CompanyCompetitor.all.map(&:feed_info)
      elsif is_chart
        @feed_infos = FeedInfo.all_sort_title(@conditions)
      end
      #feed_info_complain(@category) if @feed_infos.size < 1
    end

    def sanitize_feed_info_profile
      if current_user
        pids = current_user.profiles.map(&:id)
        _garbage = []
        @feed_infos.each do |_info|
	       return unless _info.class.equal?(FeedInfo)
           _info_profiles = _info.profiles.map(&:id)
	       _expected_remain = _info_profiles.size - pids.size
           _remain = _info_profiles - pids          
           @feed_infos = @feed_infos - [_info] if _remain.size != _expected_remain
        end
      end
    end  

    def is_show_all
      _return = false
      @category = params[:category].downcase
      if @category =~ /all/i    
        @category = @category.gsub(/all|\,/i,"")
        @category = "all_companies" if @category =~ /_companies|_company/i
        _return = true
      end
      return _return
    end
    
    def broadcast_conditions
      @conditions += "#{with_http} AND feed_infos.address ~* 'youtube'"
    end
    
    def price_conditions
      chart_conditions
    end 
    
    def is_chart
      return @category.match(/chart|price/i)
    end
    
    def is_chart_or_all_companies
      return (is_chart || is_all_companies)
    end
    
    def is_all_companies
      return @category.match(/all_companies/i)
    end
    
#     def prepare_pagination_info
# 	   @feed_infos = {:feed_infos=>@feed_infos,
#                      :current_page => @feed_infos.current_page,
#                      :per_page => @feed_infos.per_page,
#                      :total_entries => @feed_infos.total_entries,
#                      :total_pages => @feed_infos.total_pages
#                     } 
#     end
end
