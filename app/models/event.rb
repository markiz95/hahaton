class Event < ApplicationRecord
  has_many :members
  has_many :users, through: :members, dependent: :destroy
  belongs_to :creator, foreign_key: :creator_id, class_name: "User", dependent: :destroy
  has_many :taggings
  has_many :tags, through: :taggings

  def all_tags
    self.tags.map(&:name).join(', ')
  end

  def all_tags=(names)
    self.tags = names.split(',').map do |name|
      Tag.where(name: name.strip).first_or_create!
    end
  end
end
