class UsersController < ApplicationController

  before_action :set_user, only: [:show, :edit, :update, :destroy, 
                                  :accept_invitation, :reject_invitation]
  before_action :auth_check, except: [:index, :show]

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new 
  end

  def create
    @user = User.new(user_params)
    if @user.save
      log_in @user 
      flash[:success] = "Account created."
      redirect_to @user 
    else
      flash[:error] = "Failed to create account."
      render :new
    end
  end

  def edit
  end

  def update 
    if @user.update_attributes(user_params)
      flash[:success] = "Edited account."
      redirect_to @user 
    else
      flash[:error] = "Failed to edit account."
      redirect_back(fallback_location: root_path)
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = "Account deleted."
      redirect_to users_path
    else
      flash[:error] = "Failed to delete account."
      redirect_back(fallback_location: root_path)
    end
  end 

  def accept_invitation
    inv = Invitation.find_by(inviter_id: params[:accept_form][:inviter_id], 
                             invited_id: current_user.id,
                               event_id: params[:accept_form][:event_id])
    redirect_back(fallback_location: root_path) if inv.accepted? || inv.rejected?
    inv.update_attribute(:accepted, true)
    if inv.save
      Event.find(inv.event_id).attendees << current_user 
      flash[:success] = "Invitation accpeted."
      redirect_back(fallback_location: root_path)
    else
      flash[:error] = "Failed to accept invitation."
      redirect_back(fallback_location: root_path)
    end
  end

  def reject_invitation
    inv = Invitation.find_by(inviter_id: params[:accept_form][:inviter_id], 
      invited_id: current_user.id,
        event_id: params[:accept_form][:event_id])
    redirect_back(fallback_location: root_path) if inv.accepted? || inv.rejected?
    inv.update_attribute(:rejected, true)
    if inv.save
      flash[:notice] = "Invitation rejected."
      redirect_back(fallback_location: root_path)
    else
      flash[:error] = "Failed to reject invitation."
      redirect_back(fallback_location: root_path)
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def set_user
    @user = User.find(params[:id])
  end

end
