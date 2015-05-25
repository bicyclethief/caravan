require 'rails_helper'

RSpec.describe Trip, type: :model do
  let(:user) { FactoryGirl.build :user }
  let(:address) { FactoryGirl.build :address }
  let(:address2) { FactoryGirl.build :address }
  let(:origin_address_params) {{user_id: 1, description: 'house', street_address: '444 Lane', city: 'Bueno', state: 'TX', zip_code:44444}}
  let(:destination_address_params) {{user_id: 2, description: 'house', street_address: '444 Lane', city: 'Bueno', state: 'NV', zip_code:44445}}
  let(:trip_params) {{driver_id: 1, leaving_at: '9/5/2015', arriving_at: '13/5/2015', available_volume: 50, max_weight: 5, rate: 2, content_restrictions: 'flammables', vehicle: 'U-Haul'}}
  let(:trip1) { Trip.create(origin_address: address, destination_address: address, driver_id: 1, leaving_at: '9/5/2015', arriving_at: '13/5/2015', available_volume: 50, max_weight: 5, rate: Faker::Commerce.price , content_restrictions: 'matching trip', vehicle: "U-Haul Lambos")}
  let(:parcel) {Parcel.create(origin_address: address, destination_address: address2, sender_id: 2, pickup_by: '8/5/2015', deliver_by: '15/5/2015', weight: 1, volume: 10, delivery_notes: Faker::Lorem.paragraph(2), description: 'parcel 1 for testing matching trips')}

  it "is valid with a driver, origin address, destination address, leaving_at, arriving_at, available_volume, max_weight, rate, content_restrictions, vehicle" do
    expect(trip1).to be_valid
  end

  it "is invalid without a driver" do
    trip2 = trip1.update_attributes(driver_id: nil)
    expect(trip2).to eq false
  end
  it "is invalid without a destination address" do
    trip2 = trip1.update_attributes(destination_address_id: nil)
    expect(trip2).to eq false
  end
  it "is invalid without a origin address" do
    trip2 = trip1.update_attributes(origin_address_id: nil)
    expect(trip2).to eq false
  end
  it "belongs to a destination address which is an address object" do
    expect(trip1.destination_address).to be_a Address
  end
  it "belongs to an origin address which is an address object" do
    expect(trip1.origin_address).to be_a Address
  end
  it "has a class method that matches parcels by destination and dates" do
    expect(Trip.all_matching_parcel(parcel)).to eq [trip1]
  end
  it "has a class method build that returns a valid Trip when given valid params" do
    expect(Trip.build(origin_address_params, destination_address_params, trip_params)).to be_a Trip
    expect(Trip.build(origin_address_params, destination_address_params, trip_params)).to be_valid
  end
  it "has a class method build that returns an invalid Address object when given bad address params" do
    expect(Trip.build({user_id: 1}, destination_address_params, trip_params)).to be_a Address
     expect(Trip.build({user_id: 1}, destination_address_params, trip_params)).to be_invalid
  end
  it "has a class method build that returns an invalid Trip given bad trip params" do
    expect(Trip.build(origin_address_params, destination_address_params, {driver_id: 1})).to be_a Trip
    expect(Trip.build(origin_address_params, destination_address_params, {driver_id: 1})).to be_invalid
    end
end
