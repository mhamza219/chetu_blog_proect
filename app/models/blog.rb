class Blog < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  belongs_to :user

  enum status: {
    draft: 0,
    published: 1
  }

  has_many_attached :images
  has_one_attached :video
  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "description", "id", "status", "title", "updated_at", "user_id", "views"]
  end

  # def self.ransackable_attributes(auth_object = nil)
  #   %w[id title status created_at updated_at user_id]
  # end

  # # Allow searchable associations
  # def self.ransackable_associations(auth_object = nil)
  #   super + %w[
  #     user
  #     images_attachments
  #     images_blobs
  #     video_attachment
  #     video_blob
  #   ]
  # end
end
