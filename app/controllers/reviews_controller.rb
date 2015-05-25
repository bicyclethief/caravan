class ReviewsController < ApplicationController
  before_action :authenticate_user!

  def new
    @review = Review.new
    @review_carrier = Trip.find(params[:trip_id]) if params[:trip_id]
    @review_carrier = Parcel.find(params[:parcel_id]) if params[:parcel_id]
    if request.xhr?
      render 'new', layout: false
    else
      render 'new'
    end
  end

  def create
    review = Review.new(review_params)
    if params[:parcel_id]
       parcel = Parcel.find(params[:parcel_id])
       review.update_attributes(reviewee_id: parcel.sender_id)
    else
      trip = Trip.find(params[:trip_id])
      review.update_attributes(reviewee_id: trip.driver_id)
    end
    reviewee = User.find(review.reviewee_id)
    if review.save
      reputation = reviewee.get_reputation
      reviewee.update_attributes(reputation: reputation)
      redirect_to user_path(reviewee.id)
    else
      flash[:error] = review.errors.full_messages.join('<br>')
      @review = Review.new
      @review_carrier = Trip.find(params[:trip_id]) if params[:trip_id]
      @review_carrier = Parcel.find(params[:parcel_id]) if params[:parcel_id]
      render :new
    end
  end

  def destroy
    review = Review.find(params[:id])
    review.destroy
    redirect_to current_user_profile
  end

  private

  def review_params
    params.require(:review).permit(:rating, :content, :trip_id, :parcel_id, :reviewee_id).merge(reviewer_id: current_user.id)
  end

end
