class Transfer < ApplicationRecord
  belongs_to :sender, class_name: 'Cat'
  belongs_to :recipient, class_name: 'Cat'

  validates :amount, numericality: { only_integer: true, greater_than: 0 }
end
