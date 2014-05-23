class SessionsController < ApplicationController
  def new
  end
  def create
    user = User.find_by_email(params[:session][:email].downcase)
    if user
      sign_in user
      redirect_back_or user_machines_path(user)
    else
      flash.now[:error] = 'Invalid email'
      render 'new'
    end
  end
  def destroy
    sign_out
    redirect_to 'https://login.ihep.ac.cn'
  end
end
