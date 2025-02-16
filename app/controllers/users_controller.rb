class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy ]
  before_action :authorize_user_or_admin, only: [ :edit, :update, :destroy ]
  before_action :require_admin, only: [:index]

  # GET /users or /users.json
  def index
    @users = User.where(is_admin: false)
  end

  # GET /users/1 or /users/1.json
  def show
    unless session[:user_id] == @user.id || current_user&.is_admin
      flash[:alert] = "Unauthorized Access!"
      redirect_to root_path
    end
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users or /users.json
  # def create
  #   @user = User.new(user_params)
  #
  #   if @user.save
  #     session[:user_id] = @user.id  # Log in user after registration
  #     flash[:notice] = "Sign-up successful! Welcome, #{@user.username}!"
  #     redirect_to root_path
  #   else
  #     flash[:alert] = "Error creating account. Please check your inputs."
  #     render :new
  #   end
  # end
  
  # POST /users or /users.json
  def create
    @user = User.new(user_params)

    if @user.save
      flash[:notice] = "User account created successfully!"

      if current_user&.is_admin?
        # If admin is creating a user, stay logged in and redirect to users list
        redirect_to users_path
      else
        # If a normal user signs up, log them in
        session[:user_id] = @user.id
        redirect_to movies_path
      end
    else
      flash[:alert] = "Error creating account. Please check your inputs."
      render :new
    end
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    # respond_to do |format|
    if @user.update(user_params)
        # format.html { redirect_to @user, notice: "User was successfully updated." }
        # format.json { render :show, status: :ok, location: @user }
      Rails.logger.debug "Redirecting to user profile: #{@user.id}"
      flash[:notice] = "Profile updated successfully!"
      redirect_to user_path(@user)
    else
        # format.html { render :edit, status: :unprocessable_entity }
        # format.json { render json: @user.errors, status: :unprocessable_entity }
      flash[:alert] = "Error updating profile."
      render :edit
    end
    # end
  end

  # DELETE /users/1 or /users/1.json
  def destroy
    if @user.is_admin?
      flash[:alert] = "Admin account cannot be deleted!"
      redirect_to users_path and return
    end

    if current_user.is_admin? || session[:user_id] == @user.id
      @user.destroy
      flash[:notice] = "User account deleted successfully."
      redirect_to users_path
    else
      flash[:alert] = "You are not authorized to delete this user!"
      redirect_to root_path
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      Rails.logger.debug "Fetching user with ID: #{params[:id]}"
      @user = User.find_by(id: params[:id])
      if @user.nil?
        flash[:alert] = "User not found."
        redirect_to root_path
      end
    end

    def authorize_user_or_admin
      unless session[:user_id] == @user.id || current_user&.is_admin?
        flash[:alert] = "You are not authorized to edit or delete this profile!"
        redirect_to root_path
      end
    end

    # Only allow a list of trusted parameters through.
    # def user_params
    #   if current_user&.is_admin?
    #     params.require(:user).permit(:name, :email, :phone, :address)
    #   else
    #     params.require(:user).permit(:username, :name, :email, :password, :phone, :address, :credit_card_info)
    #   end
    # end

    def user_params
      if action_name == "create" && current_user&.is_admin?
        # Admin creating a normal user → Ensure is_admin = false
        params.require(:user).permit(:username, :name, :email, :password, :phone, :address, :credit_card_info).merge(is_admin: false)
      elsif current_user&.is_admin? && current_user.id == @user.id
        # Admin editing their own profile → Cannot change username, password, or ID
        params.require(:user).permit(:name, :email, :phone, :address, :credit_card_info)
      else
        # Regular user editing their own profile or admin editing another user
        params.require(:user).permit(:username, :name, :email, :password, :phone, :address, :credit_card_info)
      end
    end


end
