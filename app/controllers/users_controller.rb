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
    # respond_to do |format|
    if current_user.is_admin
      if @user == current_user
        if params[:user][:name].present? && params[:user].keys == ["name"]
          if current_user.update(name: params[:user][:name])
            flash[:notice] = "Profile updated successfully!"
            redirect_to user_path(current_user)
          else
            flash[:alert] = "Error updating profile."
            render :edit, status: :unprocessable_entity
          end
        else
          flash[:alert] = "Admins can only update their name."
          redirect_to edit_user_path(current_user)
        end
      else
        # ✅ Admin can edit other users' details
        if @user.update(user_params)
          flash[:notice] = "User details updated successfully!"
          redirect_to user_path(@user)
        else
          flash[:alert] = "Error updating user details."
          render :edit, status: :unprocessable_entity
        end
      end
    elsif User.where.not(id: @user.id).exists?(username: @user.username)
      flash[:alert] = "Username already exists. Please choose another."
      render :edit, status: :unprocessable_entity
    elsif User.where.not(id: @user.id).exists?(email: @user.email)
      flash[:alert] = "Email already exists. Please use a different email."
      render :edit, status: :unprocessable_entity
    elsif @user.update(user_params)
        # format.html { redirect_to @user, notice: "User was successfully updated." }
        # format.json { render :show, status: :ok, location: @user }
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
        params.require(:user).permit(:name)
      else
        # Regular user editing their own profile or admin editing another user
        params.require(:user).permit(:username, :name, :email, :password, :phone, :address, :credit_card_info)
      end
    end


end
