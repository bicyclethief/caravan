require 'rails_helper'

RSpec.describe Address, type: :model do
  let(:user) { FactoryGirl.build :user }
  let(:address) { FactoryGirl.build :address }

  it "is valid with a user_id, city, state, zip code" do
    expect(address).to be_valid
  end

  it "is invalid without a user_id" do
    address.update_attributes(user_id: nil)
    expect(address).to be_invalid
  end

  it "is invalid without a city" do
    address = Address.new(user: user,
                          state: Faker::Address.state_abbr,
                          zip_code: Faker::Address.zip_code)
    expect(address).to be_invalid
  end

  it "is invalid without a state" do
    address = Address.new(user: user,
                          city: Faker::Address.city,
                          zip_code: Faker::Address.zip_code)
    expect(address).to be_invalid
  end

  it "is invalid with a state longer than 2 characters" do
    address = Address.new(user: user,
                          city: Faker::Address.city,
                          state: "USA",
                          zip_code: Faker::Address.zip_code)
    expect(address).to be_invalid
  end

  it "is invalid without a zipcode" do
    address = Address.new(user: user,
                          city: Faker::Address.city,
                          state: Faker::Address.state_abbr)
    expect(address).to be_invalid
  end
end
