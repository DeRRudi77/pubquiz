# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Default login (idempotent). Dev/test only — never seed a known-password
# account into an environment that could reach production.
if Rails.env.local?
  password = ENV.fetch("SEED_ADMIN_PASSWORD", "changeme123!")
  admin = User.find_or_create_by!(email: "admin@example.com") do |u|
    u.password = password
    u.password_confirmation = password
  end

  # Game#update_rounds_and_teams (after_save) auto-creates the default
  # number_of_rounds rounds and number_of_teams teams.
  Game.create(name: "First pubquiz", user: admin)
end
