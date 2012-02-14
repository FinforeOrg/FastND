# STAGING : api.finfore.net
# LIVE    : live.finfore.net

ActionMailer::Base.default_url_options[:host] = "live.finfore.net"

ActionMailer::Base.smtp_settings = {
  :address => "secure.emailsrvr.com",
  :port => 587,
  :domain => "finfore.net",
  :authentication => :plain,
  :user_name => "info@finfore.net",
  :password => "44London",
  :enable_starttls_auto => true
}


