class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :events, through: :taggings
  acts_as_followable


end
