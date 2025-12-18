class Blog < ApplicationRecord
  validates :title, presence: true, uniqueness: true
end
