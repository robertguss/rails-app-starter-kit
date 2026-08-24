class RoundTripMessage
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :message, :string

  validates :message, presence: true, length: { maximum: 120 }
end
