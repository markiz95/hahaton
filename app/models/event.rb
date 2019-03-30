class Event < ApplicationRecord
  has_many :members
  has_many :users, through: :members
  belongs_to :creator, foreign_key: :creator_id, class_name: "User"
    # has_many :taggings, dependent: :destroy
    # has_many :tags, through: :taggings
end
