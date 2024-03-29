class FinanceController < ApplicationController
  skip_before_filter :require_user, :only => [:blog]
  caches_action :blog, :cache_path => :cache_action_name.to_proc, :gzip => :best_speed, :expires_in => 10.minutes

  def info
    tickers = clean_body(get_finance(google_finance_url))
    render :json => eval(tickers).to_json, :callback => params[:callback]
  end

  def blog
    target_url = params[:captcha] ? google_finance_url : google_blog_url
    @news = clean_body(get_finance(target_url))
    render :xml => @news.gsub(/action=\"Captcha\"/i,"action=\"\"").gsub("src=\"/sorry/","src=\"http://google.com/sorry/")
  end

  def cache_action_name
    name_path = "#{params[:q].to_s.gsub(/\W/,'_')}_#{language}_#{per_page}"
    return Digest::MD5.hexdigest(name_path)
  end

  private
    def google_finance_url
      "http://www.google.com/finance/info?infotype=infoquoteall&q=#{params[:q]}"
    end

    def google_sorry_url
      "http://www.google.com/sorry/Captcha?continue=#{CGI.escape(params[:continue])}&captcha=#{params[:captcha]}&submit=#{params[:submit]}&id=#{params[:id]}"
    end

    def google_blog_url
      "http://www.google.com/search?hl=#{language}&q=#{CGI.escape(params[:q])}&ie=utf-8&tbm=blg&num=#{per_page}&output=#{output_type}"
    end

    def get_finance(url)
      HTTParty.get(url, headers: {"User-Agent" => random_agents}, no_follow: false).body
    end

    def clean_body(result)
      result.gsub(/\n|^\/\/\s/,"").gsub(/\s\:\s/, "=>").gsub(/\"\:/,"\"=>")
    end

    def per_page
      params[:num].to_i > 0 ? params[:num] : 100
    end

    def language
      params[:hl] || "en"
    end

    def output_type
      params[:output] || "rss"
    end

    def random_agents
      [
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1312.52 Safari/537.17",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/537.13+ (KHTML, like Gecko) Version/5.1.7 Safari/534.57.2",
        "Mozilla/5.0 (iPad; CPU OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5355d Safari/8536.25",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/534.55.3 (KHTML, like Gecko) Version/5.1.3 Safari/534.53.10",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.17 (KHTML, like Gecko) Chrome/24.0.1309.0 Safari/537.17",
        "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.15 (KHTML, like Gecko) Chrome/24.0.1295.0 Safari/537.15",
        "Mozilla/5.0 (Windows NT 6.2; WOW64) AppleWebKit/537.14 (KHTML, like Gecko) Chrome/24.0.1292.0 Safari/537.14",
        "Mozilla/4.0 (compatible; MSIE 8.0; AOL 9.7; AOLBuild 4343.27; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)",
        "Mozilla/5.0 (compatible; MSIE 9.0; AOL 9.7; AOLBuild 4343.19; Windows NT 6.1; WOW64; Trident/5.0; FunWebProducts)",
        "Mozilla/4.0 (compatible; MSIE 8.0; AOL 9.6; AOLBuild 4340.5004; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)",
        "Opera/12.80 (Windows NT 5.1; U; en) Presto/2.10.289 Version/12.02",
        "Opera/9.80 (Windows NT 6.1; U; es-ES) Presto/2.9.181 Version/12.00",
        "Opera/9.80 (Windows NT 6.1; WOW64; U; pt) Presto/2.10.229 Version/11.62"
      ].shuffle.first
    end

end
