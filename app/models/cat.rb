class Cat < ApplicationRecord
  has_many :sent_transfers, class_name: 'Transfer', foreign_key: :sender_id, dependent: :restrict_with_exception
  has_many :received_transfers, class_name: 'Transfer', foreign_key: :recipient_id, dependent: :restrict_with_exception

  validates :name, presence: true
  validates :treats_balance, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
