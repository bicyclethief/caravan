class Trip < ActiveRecord::Base
  include DateHelpers
  belongs_to :driver, class_name: "User"
  has_many :parcels
  has_many :reviews
  belongs_to :origin_address, class_name: "Address"
  belongs_to :destination_address, class_name: "Address"

  validates :origin_address_id, :destination_address_id, :driver_id, presence: :true
  validates :leaving_at, :arriving_at, :available_volume, :rate, presence: :true

  validates_associated :origin_address, :destination_address

  SEARCH_RADIUS_MILES = 15

  def self.search(origin, destination, parcel)
    trips_found = []

    if origin && origin.latitude && origin.longitude
      trips_near_origin = trips_near(origin.latitude, origin.longitude, :origin_address_id)
      if trips_near_origin.empty?
        return trips_near_origin
      else
        trips_found = trips_near_origin
      end
    end

    if destination && destination.latitude && destination.longitude
      trips_near_destination = trips_near(destination.latitude, destination.longitude, :destination_address_id)
      if trips_near_destination.empty?
        return trips_near_destination
      else
        if trips_found.empty?
          trips_found = trips_near_destination
        else
          trips_found = trips_found.merge(trips_near_destination)
        end
      end
    end

    if parcel && !trips_found.empty?
      trips_found = trips_found.where("leaving_at > ?", parcel.pickup_by.to_formatted_s(:app)) if parcel.pickup_by
      trips_found = trips_found.where("arriving_at < ?", parcel.deliver_by.to_formatted_s(:app)) if parcel.deliver_by
      trips_found = trips_found.where("max_weight > ?", parcel.weight) if parcel.weight
      trips_found = trips_found.where("available_volume > ?", parcel.volume) if parcel.volume
    end

    trips_found
  end

  def self.build(origin_address_params, destination_address_params, trip_params)
    origin_address = Address.new(origin_address_params)
    unless origin_address.save
      return origin_address
    end

    destination_address = Address.new(destination_address_params)
    unless destination_address.save
      origin_address.destroy
      return destination_address
    end

    trip_params[:leaving_at] = Date.strptime(trip_params[:leaving_at], '%m/%d/%Y').strftime('%d/%m/%Y')
    trip_params[:arriving_at] = Date.strptime(trip_params[:arriving_at], '%m/%d/%Y').strftime('%d/%m/%Y')

    trip = Trip.new(trip_params)
    trip.origin_address = origin_address
    trip.destination_address = destination_address

    if trip.save
      return trip
    else
      origin_address.destroy
      destination_address.destroy
      trip.destroy
      return trip
    end
  end

  def self.all_matching_parcel(parcel)
    matching_trips = Trip.joins(:destination_address).where('addresses.city = ? and addresses.state = ?', parcel.destination_address.city, parcel.destination_address.state).where('arriving_at < ? and leaving_at > ?', parcel.deliver_by, parcel.pickup_by)
    matching_trips = matching_trips.where('max_weight > ?', parcel.weight) if parcel.weight
    matching_trips = matching_trips.where('available_volume > ?', parcel.volume) if parcel.volume
  end

  def notify_driver(parcel)
    driver.notify("Your trip has a confirmed parcel: Details", "You have accepted to ship parcel ID\##{parcel.id} for #{parcel.sender.username} by #{format_date(parcel.pickup_by)} and deliver by #{format_date(parcel.deliver_by)}.")
  end

  private

  def self.trips_near(latitude, longitude, source)
    if latitude && longitude
      addresses_nearby = Address.near([latitude, longitude], SEARCH_RADIUS_MILES)
      address_ids = addresses_nearby.map { |address| address.id }
      trips = Trip.where(source => address_ids)
    else
      []
    end
  end
end
