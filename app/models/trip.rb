class Trip < ActiveRecord::Base
  belongs_to :driver, class_name: "User"
  has_many :parcels
  has_many :reviews
  belongs_to :origin_address, class_name: "Address"
  belongs_to :destination_address, class_name: "Address"

  validates :origin_address_id, :destination_address_id, :driver_id, presence: :true
  validates :leaving_at, :arriving_at, :available_volume, :rate, presence: :true

  validates_associated :origin_address, :destination_address

  SEARCH_RADIUS_MILES = 15

  def self.search(params)
    trips_found = []

    if params[:origin_address] && !params[:origin_address][:latitude].empty? && !params[:origin_address][:longitude].empty?
      trips_near_origin = trips_near(params[:origin_address][:latitude], params[:origin_address][:longitude], :origin_address_id)
      if trips_near_origin.count == 0
        return trips_near_origin
      else
        trips_found = trips_near_origin
      end
    end

    if params[:destination_address] && !params[:destination_address][:latitude].empty? && !params[:destination_address][:longitude].empty?
      trips_near_destination = trips_near(params[:destination_address][:latitude], params[:destination_address][:longitude], :destination_address_id)
      if trips_near_destination.count == 0
        return trips_near_destination
      else
        trips_found = trips_found.merge(trips_near_destination)
      end
    end

    if params[:parcel]
      trips_found = trips_found.where("leaving_at > ?", date_from_euro_string(params[:parcel][:pickup_by])) if !params[:parcel][:pickup_by].empty?
      trips_found = trips_found.where("arriving_at < ?", date_from_euro_string(params[:parcel][:deliver_by])) if !params[:parcel][:deliver_by].empty?
      trips_found = trips_found.where("max_weight > ?", params[:parcel][:weight]) if !params[:parcel][:weight].empty?
      trips_found = trips_found.where("available_volume > ?", params[:parcel][:volume]) if !params[:parcel][:volume].empty?
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

  private

  def self.date_from_euro_string str
    p "xxxxxxxxxxx"
    p str
   return DateTime.strptime(str, "%d/%m/%Y %H:%M:%S") if str
  end

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
