class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :blogs

  has_many :messages
  has_many :participants
  has_many :rooms, through: :participants


  def self.ransackable_attributes(auth_object = nil)
    # %w[id email created_at updated_at]
    column_names
  end

  def self.ransackable_associations(auth_object = nil)
    %w[blogs]
  end
end
