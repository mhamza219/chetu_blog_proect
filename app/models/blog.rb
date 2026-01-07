class Blog < ApplicationRecord
  validates :title, presence: true, uniqueness: true
  belongs_to :user,touch: true

  after_create_commit :send_created_email
  after_destroy_commit :send_deleted_email

  enum status: {
    draft: 0,
    published: 1
  }

  has_many_attached :images
  has_one_attached :video

  # after_touch :custom_method
  after_touch do
    Rails.logger.info("A Book was touched")
  end




  def self.ransackable_associations(auth_object = nil)
    ["user"]
  end
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "description", "id", "status", "title", "updated_at", "user_id", "views"]
  end


  private

  def custom_method
    puts "call custom method"
  end

  def send_created_email
    BlogMailer.blog_created(self).deliver_later
  end

  def send_deleted_email
    BlogMailer.blog_deleted(self).deliver_later
  end
end
