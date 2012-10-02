require 'spec_helper'

describe UserMailer do
	before(:each) do
  	@user = FactoryGirl.create(:yacobus)
  end
	
	describe 'welcome_email' do
		let(:mail) { UserMailer.welcome_email(@user,'asdasdasd') }

		#ensure that the subject is correct
		it 'renders the subject' do
			mail.subject.should == 'FASTND.COM - Welcome to FastND'
		end

		#ensure that the receiver is correct
		it 'renders the receiver email' do
			mail.to.should == [@user.email_work]
		end

		#ensure that the sender is correct
		it 'renders the sender email' do
			mail.from.should == ['info@fastnd.com']
		end

		#ensure that the full_name variable appears in the email body
		it 'assigns full name' do
			mail.body.encoded.should match(@user.full_name)
		end
		
		#ensure that the password variable appears in the email body
		it 'assigns password' do
			mail.body.encoded.should match('asdasdasd')
		end
	end
	
	describe 'forgot_password' do
		let(:mail) { UserMailer.forgot_password(@user,'qwertyqwerty') }
	
		#ensure that the subject is correct
		it 'renders the subject' do
			mail.subject.should == 'FastND - Forgot Password and Email'
		end
	
		#ensure that the receiver is correct
		it 'renders the receiver email' do
			mail.to.should == [@user.email_work]
		end
	
		#ensure that the sender is correct
		it 'renders the sender email' do
			mail.from.should == ['info@fastnd.com']
		end
	
		#ensure that the full_name variable appears in the email body
		it 'assigns full name' do
			mail.body.encoded.should match(@user.full_name)
		end
		
		#ensure that the password variable appears in the email body
		it 'assigns password' do
			mail.body.encoded.should match('qwertyqwerty')
		end
	end
	
end