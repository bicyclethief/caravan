class Parcel < ActiveRecord::Base
  has_many :reviews
  belongs_to :sender, class_name: "User"
  belongs_to :trip
  belongs_to :origin_address, class_name: "Address"
  belongs_to :destination_address, class_name: "Address"

  validates :origin_address_id, :destination_address_id, :sender_id, presence: true
  validates :pickup_by, :deliver_by, :volume, presence: true
  validates_associated :origin_address, :destination_address

  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"

  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/


  def self.build(origin_address_params, destination_address_params, parcel_params)
    origin_address = Address.new(origin_address_params)
    unless origin_address.save
      return origin_address
    end

    destination_address = Address.new(destination_address_params)
    unless destination_address.save
      origin_address.destroy
      return destination_address
    end

    parcel = Parcel.new(parcel_params)
    parcel.origin_address = origin_address
    parcel.destination_address = destination_address
    parcel.sender = origin_address.user
    if parcel.save
      return parcel
    else
      origin_address.destroy
      destination_address.destroy
      parcel.destroy
      return parcel
    end
  end
end
