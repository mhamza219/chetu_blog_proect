class Blog < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  belongs_to :user

  enum status: {
    draft: 0,
    published: 1
  }

  has_many_attached :images
  has_one_attached :video
end
