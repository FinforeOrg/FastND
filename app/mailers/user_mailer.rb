class UserMailer < ActionMailer::Base
  default :to => "info@fastnd.com"

  def welcome_email(user,password)
    @user = user
    @password = password
    mail(:subject => "FASTND.COM - Welcome to FastND", :from => user.login)
    new_user_to_admin(user)
   end

   def new_user_to_admin(user)
     @user = user
     mail(:subject => "FastND - New Member", :from => "info@fastnd.com")
   end

   def contact(to, subject, options)
     @body = options.merge!({:sent_on => Time.now})
     mail(:subject => subject, :from => options[:email])
   end
   
   
   def missing_suggestions(user,category)
     category = category.gsub(/all_companies/i,"company tab")
     subject = "Issue #"+ rand(100000).to_s+" : Missing suggestion for #{category}"
     @body = {:user => user, :column_type => category, :sent_on => Time.now}
     mail(:subject => subject, :from => user.login)
   end

   def forgot_password(user,new_password)
     @body = { :login_email => user.login,
               :password => new_password,
               :sent_on => Time.now,
               :full_name => user.full_name
             }
     mail(:subject => "FastND - Forgot Password and Email", :from => "info@fastnd.com", :to => user.login)
   end

end
