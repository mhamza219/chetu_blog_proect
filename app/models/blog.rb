class Blog < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  belongs_to :user
end
