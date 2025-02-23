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

    if User.exists?(username: @user.username)
      flash[:alert] = "Username already exists. Please choose another."
      render :new, status: :unprocessable_entity
    elsif User.exists?(email: @user.email)
      flash[:alert] = "Email already exists. Please use a different email."
      render :new, status: :unprocessable_entity
    elsif @user.save
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
    if current_user.is_admin
      if @user == current_user
        return update_admin_details if params[:user]&.keys&.all? { |key| %w[name email].include?(key) } && (params[:user][:name].present? || params[:user][:email].present?)
        flash[:alert] = "Admins can only update their name and Email."
        return redirect_to edit_user_path(current_user)
      else
        return update_user_details
      end
    end
    
    return render_error("Username already exists. Please choose another.") if username_taken?
    return render_error("Email already exists. Please use a different email.") if email_taken?
    return update_user_details
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

      if session[:user_id] == @user.id
        session[:user_id] = nil  # Clear session if user deleted their own account
        redirect_to login_path and return
      end

      redirect_to users_path
    else
      flash[:alert] = "You are not authorized to delete this user!"
      redirect_to root_path
    end
  end

  private

  def update_admin_details
    if current_user.update(user_params)
      flash[:notice] = "Profile updated successfully!"
      redirect_to user_path(current_user)
    else
      flash[:alert] = current_user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def update_user_details
    if @user.update(filtered_user_params)
      flash[:notice] = "User details updated successfully!"
      redirect_to user_path(@user)
    else
      flash[:alert] = @user.errors.full_messages.to_sentence
      render :edit, status: :unprocessable_entity
    end
  end

  def filtered_user_params
    filtered_params = user_params.dup
    if filtered_params[:password].blank?
      filtered_params.delete(:password)
    end
    filtered_params
  end

  def username_taken?
    User.where.not(id: @user.id).exists?(username: @user.username)
  end

  def email_taken?
    User.where.not(id: @user.id).exists?(email: @user.email)
  end

  def render_error(message)
    flash[:alert] = message
    render :edit, status: :unprocessable_entity
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_user
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
      params.require(:user).permit(:name, :email)
    else
      # Regular user editing their own profile or admin editing another user
      params.require(:user).permit(:username, :name, :email, :password, :phone, :address, :credit_card_info)
    end
  end
end
