# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
 User.create!(
   username: "admin",
   name: "Admin user",
   email: "admin@admin.com",
   password: "admin123",
   credit_card_info: "1234-1234-1234-1234",
   is_admin: true
 )

# Create 6 screens
6.times do |i|
  Screen.find_or_create_by!(name: "Screen #{i + 1}") do |screen|
    screen.capacity = 100  # Adjust the capacity as needed
  end
end

puts "✅ Seeded 6 screens successfully!"
