class PortfoliosController < ApplicationController
  require 'gmoney'
  require 'open-uri'
  require 'net/http'
  require 'portfolio_event'

  before_filter :set_cache_buster  
  before_filter :prepare_gmoney, :except => [:delete_portfolio, :save_portfolio,:save_transaction]
  before_filter :login_with_account_id, :only => [:delete_portfolio, :save_portfolio,:save_transaction]
  DEFAULT_USERNAME = 'testuserfinfore@gmail.com'
  DEFAULT_PASSWORD = '44London'

  #caches_action :agenda, :cache_path => Proc.new { |controller| controller.params }, :expires_in => 4.hours
  #caches_action :overviews, :cache_path => Proc.new { |controller| controller.params }, :expires_in => 2.hours
  caches_action :public_login, :cache_path => Proc.new { |c| c.params }, :expires_in => 72.hours
  caches_action :list, :cache_path => Proc.new { |c| c.params }, :expires_in => 72.hours
  
  def agenda
    tickers = params[:tickers].split("|")
    pe = PortfolioEvent.new
    pe.from_ticker(tickers)
    respond_to do |format|
      format.xml  { render :xml => pe.results }
      format.json  { render :json => Hash.from_xml(pe.results) }
    end
	rescue => e
      respond_to do |format|
        format.xml  { render :xml => e.to_xml, :status => :unprocessable_entity }
        format.json { render :json => e.to_json, :status => :unprocessable_entity }
      end
  end

  def save_transaction
   transaction = params[:tid].blank? ? @gm::Transaction.new : @gm::Transaction.find(params[:tid])
   transaction.portfolio = params[:portfolio_id] if params[:tid].blank?  #Must be a valid portfolio id
   transaction.ticker = params[:google_ticker] if params[:tid].blank?    #Must be a valid ticker symbol
   transaction.type = params[:category]  #Must be one of the following: Buy, Sell, Sell Short, Buy to Cover
   transaction.shares = params[:shares] unless params[:shares].blank?
   transaction.price = params[:price] unless params[:price].blank?
   transaction.commission = params[:commission] unless params[:commission].blank?
   transaction.save #returns transaction object
   footer_method
   rescue => e
      respond_to do |format|
        format.xml  { render :xml => e.to_xml, :status => :unprocessable_entity }
        format.json { render :json => e.to_json, :status => :unprocessable_entity }
      end
  end

  def delete_transaction
    if params[:with_company]
      @gm::Position.delete params[:pid]
    else
      @gm::Transaction.delete params[:tid]
    end
    footer_method
	rescue => e
      respond_to do |format|
        format.xml  { render :xml => e.to_xml, :status => :unprocessable_entity }
        format.json { render :json => e.to_json, :status => :unprocessable_entity }
      end
  end

  def save_portfolio
    if params[:portfolio_id].blank?
      portfolio = @gm::Portfolio.new
    else
      portfolio = @gm::Portfolio.find params[:portfolio_id].split("/").last
    end
    portfolio.title = params[:title]
    portfolio.currency_code = params[:currency]
    portfolio.save
    list
  end

  def delete_portfolio
    @gm::Portfolio.delete params[:portfolio_id].split("/").last unless params[:portfolio_id].blank?
    list
  end

  def list
    if @isAuthorized
      portfolios = @gm::Portfolio.all
      portfolios = [portfolios] if portfolios.class.name == "GMoney::Portfolio"
      portfolios.each do |portfolio|
        @rss_portfolio << create_item_portfolio(portfolio)
      end    
    end
    footer_method
	rescue => e
      respond_to do |format|
        format.xml  { render :xml => e.to_xml, :status => :unprocessable_entity }
        format.json { render :json => e.to_json, :status => :unprocessable_entity }
      end
  end

  def overviews
    if params[:portfolio_id]
      portfolio = @gm::Portfolio.find params[:portfolio_id]
      tickers = portfolio.positions.map{|position| {:ticker => position.pid.split("/")[1], :name => position.title}}
      tickers.each do |overview|
        if !overview.blank?
          @rss_portfolio << "<item>
            <google_ticker>#{overview[:ticker]}</google_ticker>
            <name>#{overview[:name]}</name>
          </item>
          "
        end
      end
    end
    footer_method
 rescue => e
      respond_to do |format|
        format.xml  { render :xml => e.to_xml, :status => :unprocessable_entity }
        format.json { render :json => e.to_json, :status => :unprocessable_entity }
      end

  end

  def positions
    if params[:portfolio_id]
      portfolio = @gm::Portfolio.find params[:portfolio_id]
      portfolio.positions.each do |position|
        @rss_portfolio << create_item_position(position)
      end
    end
    footer_method
	rescue => e
      respond_to do |format|
        format.xml  { render :xml => e.to_xml, :status => :unprocessable_entity }
        format.json { render :json => e.to_json, :status => :unprocessable_entity }
      end
  end

  def transactions
    if params[:portfolio_id]
      portfolio = @gm::Portfolio.find params[:portfolio_id]
      pids = portfolio.positions.map(&:pid)
      pids.each do |pid|
        begin
          transaction = @gm::Transaction.find(pid)
          if !transaction.ticker.blank?
          @rss_portfolio << "<item>
            <google_ticker>#{transaction.ticker}</google_ticker>
            <category>#{transaction.type}</category>
            <shares>#{transaction.shares}</shares>
            <price>#{transaction.price}</price>
            <pid>#{pid}</pid>
            <tid>#{transaction.tid}</tid>
            <commission>#{transaction.commission}</commission>
          </item>"
          end
        rescue
        end
      end
    end
    footer_method
	rescue => e
      respond_to do |format|
        format.xml  { render :xml => e.to_xml, :status => :unprocessable_entity }
        format.json { render :json => e.to_json, :status => :unprocessable_entity }
      end
  end
  
private
  def prepare_gmoney
    @gm = GMoney
    if params[:feed_account_id].blank?
      prepare_rss_portfolio
      @gm::GFSession.logout
      @gm::GFSession.login(DEFAULT_USERNAME,DEFAULT_PASSWORD)
    else
      login_with_account_id
    end
  end

  def login_with_account_id
    if @gm.blank?
      @gm = GMoney
      @gm::GFSession.logout
    end
    @isAuthorized = true
    prepare_rss_portfolio
    @account = current_user.feed_accounts.find(params[:feed_account_id])
    ft = @account.feed_token
    unless ft.blank?
      fa = FeedApi.auth_by('google')
      @gm::GFSession.login_oauth({:consumer_key => fa.api,:consumer_secret=> fa.secret, :token=>ft.token, :secret=>ft.secret})
    end
  end

  def prepare_rss_portfolio
    @rss_portfolio = <<-EOF
      <rss xmlns:dc="http://purl.org/dc/elements/1.1/"  xmlns:atom="http://www.w3.org/2005/Atom" >
        <chanel>
    EOF
  end

  def getQuotes(symbol,company_name)
    h = Net::HTTP.new('www.google.com')
    response = h.get('/finance?q='+symbol)

    if response.message == "OK"
       pr = response.body.scan(/class="pr">[\n].*">([0-9]*\.?[0-9]*)<\/span>/)[0].to_a.join
       chg = response.body.scan(/class="ch bld">.*">([-+]?[0-9]*\.?[0-9]*)<\/span>/)[0].to_a.join
       chg_pct = response.body.scan(/class="ch[g|r]".*">(\([-+]?[0-9]*\.?[0-9]*%\))<\/span>/)[0].to_a.join
       mkt_cap = response.body.scan(/Mkt cap<\/span>\n.*goog-inline-block val">(.*)<\/span>/)[0].to_a.join.gsub("<span class=dis>*</span>","")
       if !symbol.blank?
       @rss_portfolio << "<item>
          <google_ticker>#{symbol}</google_ticker>
          <mkt_cap>#{checkValue(mkt_cap)}</mkt_cap>
          <pct_chg>#{checkValue(chg_pct).gsub(/(\(|\))/,'')}</pct_chg>
          <chg>#{checkValue(chg)}</chg>
          <price>#{checkValue(pr)}</price>
          <name>#{company_name}</name>
        </item>"
        end
      return @rss_portfolio
    end
   end

   def checkValue(price)
     return price.gsub(/\&nbsp;\&nbsp;\&nbsp;\&nbsp;-/,"0.0")
   end

   def create_item_portfolio(data)
     return "<item>
              <id>#{data.id}</id>
              <feed_link>#{data.feed_link}</feed_link>
              <currency_code>#{data.currency_code}</currency_code>
              <title>#{data.title}</title>
            </item>"
   end

   def create_item_position(data)
     ticker = data.pid.split("/")[1]
     if !ticker.blank?
       result = "<item>
              <google_ticker>#{ticker}</google_ticker>
              <pid>#{data.pid}</pid>
              <return_overall>#{data.return_overall}</return_overall>
              <gain>#{(data.gain.blank? ? 0.0 : data.gain)}</gain>
              <gain_percentage>#{data.gain_percentage}</gain_percentage>
              <cost_basis>#{(data.cost_basis.blank? ? 0.0 : data.cost_basis)}</cost_basis>
            </item>"
      else
        result = ""
      end
     return result
   end

   def footer_method
     @rss_portfolio << "</chanel></rss>"
     @rss_portfolio = @rss_portfolio.gsub(/\&/ixm,'#26amp;')
    respond_to do |format|
      format.xml  { render :xml => @rss_portfolio }
      format.json { render :json => Hash.from_xml(@rss_portfolio) }
    end
   end

  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

  
end

       #pe = response.body.scan(/P\/E<\/span>\n.*goog-inline-block val">(.*)<\/span>/)[0].to_a.join
       # yld = response.body.scan(/Div\/yield<\/span>\n.*goog-inline-block val">.*\/(.*)<\/span>/)[0].to_a.join
       #eps = response.body.scan(/EPS<\/span>\n.*">([0-9]*\.?[0-9]*)<\/span>/)[0].to_a.join
       #shares = response.body.scan(/Shares<\/span>\n.*goog-inline-block val">(.*)<\/span>/)[0].to_a.join
       #beta = response.body.scan(/Beta<\/span>\n.*">([0-9]*\.?[0-9]*)<\/span>/)[0].to_a.join
       #inst_own = response.body.scan(/Inst. own<\/span>\n.*">([0-9]*\.?[0-9]*%)<\/span>/)[0].to_a.join
       #hi = response.body.scan(/Range<\/span>\n.*">([0-9]*\.?[0-9]*) - [0-9]*\.?[0-9]*<\/span>/)[0].to_a.join
       #low = response.body.scan(/Range<\/span>\n.*">[0-9]*\.?[0-9]* - ([0-9]*\.?[0-9]*)<\/span>/)[0].to_a.join
       #year_hi = response.body.scan(/ week<\/span>\n.*">([0-9]*\.?[0-9]*) - [0-9]*\.?[0-9]*<\/span>/)[0].to_a.join
       #year_low = response.body.scan(/ week<\/span>\n.*">[0-9]*\.?[0-9]* - ([0-9]*\.?[0-9]*)<\/span>/)[0].to_a.join
       #open = response.body.scan(/Open<\/span>\n.*">([0-9]*\.?[0-9]*)<\/span>/)[0].to_a.join
       #vol = response.body.scan(/Vol\.<\/span>\n.*goog-inline-block val">(.*)<\/span>/)[0].to_a.join
       #avg_vol = response.body.scan(/Vol\/Avg\.<\/span>\n.*goog-inline-block val">(.*)<\/span>/)[0].to_a.join
