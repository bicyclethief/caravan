class TripsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]

  def search
    if params[:parcel_id]
      parcel = Parcel.find(params[:parcel_id])
      origin_address = parcel.origin_address
      destination_address = parcel.destination_address
      params[:origin_address] = {}
      params[:destination_address] = {}
      params[:parcel] = {}
      @parcel_id = parcel.id
      @origin_address_string = params[:origin_address][:address_string] = origin_address.address_string
      @origin_latitude = params[:origin_address][:latitude] = origin_address.latitude.to_s
      @origin_longitude = params[:origin_address][:longitude] = origin_address.longitude.to_s

      @destination_address_string = params[:destination_address][:address_string] = destination_address.address_string
      @destination_latitude = params[:destination_address][:latitude] = destination_address.latitude.to_s
      @destination_longitude = params[:destination_address][:longitude] = destination_address.longitude.to_s

      @pickup_by = params[:parcel][:pickup_by] = parcel.pickup_by.to_formatted_s(:app)
      @deliver_by = params[:parcel][:deliver_by] = parcel.deliver_by.to_formatted_s(:app)
      @weight = params[:parcel][:weight] = parcel.weight.to_s
      @volume = params[:parcel][:volume] = parcel.volume.to_s
    else
      if params[:origin_address]
        @origin_address_string = params[:origin_address][:address_string]
        @origin_latitude = params[:origin_address][:latitude]
        @origin_longitude = params[:origin_address][:longitude]
      end

      if params[:destination_address]
        @destination_address_string = params[:destination_address][:address_string]
        @destination_latitude = params[:destination_address][:latitude]
        @destination_longitude = params[:destination_address][:longitude]
      end

      if params[:parcel]
        @pickup_by = params[:parcel][:pickup_by]
        @deliver_by = params[:parcel][:deliver_by]
        @weight = params[:parcel][:weight]
        @volume = params[:parcel][:volume]
      end
    end

    @trips = Trip.search(params)
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
      notify_sender(@parcel)
      notify_driver(@trip, @parcel)
      @trip.available_volume -= @parcel.volume
      @trip.save
    else
      flash[:error] = @parcel.errors.full_messages.join('<br>')
      redirect_to parcel_trips_path(@parcel)
    end
  end

  private

  def notify_sender
    parcel.sender.notify("Your parcel is booked: Details", "Your parcel ID\##{parcel.id} will be picked up by #{format_date(parcel.pickup_by)} and delivered by #{format_date(parcel.deliver_by)} by driver #{parcel.trip.driver.username}.")
  end

  def notify_driver(trip, parcel)
    trip.driver.notify("Your trip has a confirmed parcel: Details", "You have accepted to ship parcel ID\##{parcel.id} for #{parcel.sender.username} by #{format_date(parcel.pickup_by)} and deliver by #{format_date(parcel.deliver_by)}.")
  end

  def origin_address_params
    params.require(:origin_address).permit(:description, :street_address, :secondary_address, :city, :state, :zip_code,:latitude, :longitude).merge(user_id: current_user.id)
  end

  def destination_address_params
    params.require(:destination_address).permit(:description, :street_address, :secondary_address, :city, :state, :zip_code,:latitude,:longitude).merge(user_id: current_user.id)
  end

  def trip_params
    params.require(:trip).permit(:leaving_at, :arriving_at, :available_volume, :max_weight, :rate, :content_restrictions, :vehicle).merge(driver_id: current_user.id)
  end
end