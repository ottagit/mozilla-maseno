class AccountActivationsController < ApplicationController

  def edit
    user = User.find_by(email: params[:email])
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "Yay! Account successfully activated."
      redirect_to user
    else
      flash[:danger] = "The account activation link is invalid."
      redirect_to root_url
    end
  end
end
