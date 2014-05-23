class PagesController < ApplicationController
  def home
    if signed_in?
      redirect_to user_machines_path(current_user)
    end
  end
  def about
  end
  def dashboard
  end
  def callback
    data={
      client_id:ENV['APP_KEY'],
      client_secret:ENV['APP_SECRET'],
      grant_type:"authorization_code",
      redirect_uri:ENV['REDIRECT_URI'],
      code:params[:code]
    }
    res=Net::HTTP.post_form(URI.parse("https://login.ihep.ac.cn/oauth2/token"),data)
    body=res.body.gsub('\\','')
    body=body.gsub('"{','{')
    body=body.gsub('}"','}')
    body=JSON.parse(body)
    user = User.find_or_create_by(email:body["userInfo"]["cstnetId"].downcase)
    if user
      user.name=body["userInfo"]["truename"]
      user.save!
      sign_in user
      redirect_back_or user_machines_path(user)
    else
      flash.now[:error] = 'Invalid email'
      render 'home'
    end
  end
end
