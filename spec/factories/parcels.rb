FactoryGirl.define do
  factory :parcel do
    id 1
    weight 4
    volume 3
    description "pet cat"
    pickup_by Date.parse('1995-03-03')
    deliver_by Date.parse('1995-04-04')
    sender_id 1
    delivery_notes "fragile"
    association :destination_address, factory: :address
    association :origin_address, factory: :address
    association :trip, factory: :trip
  end
end
