# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password') if Rails.env.development?
# 10.times do |i|
#   Blog.create(title: Faker::Name.name, description: Faker::Markdown.emphasis, user_id: 2 )
# end

Product.destroy_all

# Note: prices are in cents (1000 = $10.00)
Product.create!([
  { title: "Standard T-Shirt", description: "100% Cotton", price: 2000 },
  { title: "Coffee Mug", description: "Ceramic 12oz", price: 1500 },
  { title: "Ruby Sticker", description: "High quality vinyl", price: 500 }
])

puts "Created #{Product.count} products."