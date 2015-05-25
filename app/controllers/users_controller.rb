class UsersController < ApplicationController

  before_action :authenticate_user!, except: [:create]

  def create
    user = User.new(user_params)
    if user.save
      session[:user_id] = user.id
      redirect_to user_path(user.id)
    else
      redirect_to new_user_path
    end
  end

  def show
    @user = User.find(params[:id])
    @reviews = Review.where(reviewee_id: @user.id)
    @reviewer = false
  end

  def current
    # look into eager loading
    @user = current_user
    @parcels = @user.parcels.where(delivered: false).order(updated_at: :desc)
    @trips = @user.trips.where(completed: false).order(updated_at: :desc )
    @notifications = @user.mailbox.notifications
    @conversations = @user.mailbox.inbox
    @num_messages = @conversations.count + @notifications.count
    render 'current' # layout: false
  end

  def history
    @user = current_user
    @trips = Trip.where(driver: @user, completed: true)
    @parcels = Parcel.where(sender: @user, delivered: true)
    if request.xhr?
      render 'history', layout: false
    else
      render 'history'
    end
  end

  private

  def user_params
    params.require(:user).permit(:username, :password)
  end

end