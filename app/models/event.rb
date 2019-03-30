class Event < ApplicationRecord
  has_many :members
  has_many :users, through: :members, dependent: :destroy
  belongs_to :creator, foreign_key: :creator_id, class_name: "User", dependent: :destroy
  has_many :taggings
  has_many :tags, through: :taggings
end
