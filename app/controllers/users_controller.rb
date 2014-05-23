class UsersController < ApplicationController
  before_action :signed_in_user,only: [:show]
  before_action :correct_user,only:[:show]
  before_action :admin_user,only: [:index,:edit,:update]

  def index
    @users = User.paginate(page:params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
  end

  def update
    if @user.update(user_params)
      flash[:success]= "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email)
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_url) unless (current_user.admin? or current_user.superadmin?)
    end
end
