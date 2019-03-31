class Event < ApplicationRecord
  has_many :members, dependent: :destroy
  has_many :users, through: :members
  belongs_to :creator, foreign_key: :creator_id, class_name: "User"
  has_many :taggings
  has_many :tags, through: :taggings
  acts_as_followable

  def all_tags
    self.tags.map(&:name).join(', ')
  end

  def all_tags=(names)
    self.tags = names.split(',').map do |name|
      Tag.where(name: name.strip.downcase).first_or_create!
    end
  end
end
