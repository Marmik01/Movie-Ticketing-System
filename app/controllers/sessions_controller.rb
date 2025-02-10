class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(username: params[:username])
    if user && user.password == params[:password]
      session[:user_id] = user.id
      flash[:notice] = "Logged in successfully!"
      redirect_to root_path
    else
      flash[:alert] = "Invalid username or password"
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "Logged out successfully!"
    redirect_to root_path
  end
end
