class TripsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]

  def search
    if params[:parcel_id]
      @parcel = Parcel.find(params[:parcel_id])
      @parcel_matching = true if @parcel && @parcel.valid?
      @origin = @parcel.origin_address
      @destination = @parcel.destination_address
      @trips = Trip.search(@origin, @destination, @parcel)
    else
      @origin_address = Address.new_from_params(params[:origin_address]) if params[:origin_address]
      @destination_address = Address.new_from_params(params[:destination_address]) if params[:destination_address]
      @parcel = Parcel.new_from_params(params[:parcel]) if params[:parcel]
      @trips = Trip.search(@origin_address, @destination_address, @parcel)
    end
  end

  def new
    @url = trips_path
    @method = :post
    @submit_btn = "Create Trip"
    @address = Address.new
  end

  def show
    @trip = Trip.find(params[:id])
    if request.xhr?
      render 'show', layout: false
    else
      render 'show'
    end
  end

  def edit
    @trip = Trip.find(params[:id])
    @origin_address = @trip.origin_address
    @destination_address = @trip.destination_address
    @url = trip_path
    @submit_btn = "Update Trip"
  end

  def update
    @trip = Trip.find(params[:id])
    @origin_address = @trip.origin_address
    @destination_address = @trip.destination_address

    if @trip.update(trip_params)
      @trip.origin_address.update(origin_address_params)
      @trip.destination_address.update(destination_address_params)
      redirect_to current_user_profile
    else
      render :edit
    end
  end

  def destroy
    trip = Trip.find(params[:id])
    trip.destroy
    redirect_to current_user_profile
  end

  def create
    trip = Trip.build(origin_address_params, destination_address_params, trip_params)

    if trip && trip.id
      redirect_to profile_path
    else
      flash[:error] = trip.errors.full_messages.join(', ')
      # TODO: recycle params so user does not have to re-input
      render :new
    end
  end

  def book
    @parcel = Parcel.find(params[:parcel_id])
    @trip = Trip.find(params[:id])
    if @parcel.update(trip: @trip)
      @parcel.notify_sender
      @trip.notify_driver(@parcel)
      @trip.available_volume -= @parcel.volume
      @trip.save
    else
      flash[:error] = @parcel.errors.full_messages.join('<br>')
      redirect_to parcel_trips_path(@parcel)
    end
  end

  private

  def origin_address_params
    params.require(:origin_address).permit(:description, :street_address, :secondary_address, :city, :state, :zip_code,:latitude, :longitude, :address_string).merge(user_id: current_user.id)
  end

  def destination_address_params
    params.require(:destination_address).permit(:description, :street_address, :secondary_address, :city, :state, :zip_code,:latitude,:longitude, :address_string).merge(user_id: current_user.id)
  end

  def trip_params
    params.require(:trip).permit(:leaving_at, :arriving_at, :available_volume, :max_weight, :rate, :content_restrictions, :vehicle).merge(driver_id: current_user.id)
  end
end