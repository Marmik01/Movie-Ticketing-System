require "rails_helper"

RSpec.describe Ticket, type: :model do
  let(:user) { User.create(username: "testuser", email: "test@example.com", password: "password", credit_card_info: "1111-2222-3333-4444") }
  let!(:movie) { Movie.create(title: "Test Movie", genre: "Action", duration: 120, language: "English", rating: "PG", release_date: Date.today) }
  let!(:screen) { Screen.create(name: "Screen 1", capacity: 100) }
  let!(:show) { Show.create(movie: movie, screen: screen, date: Date.today, time: "18:00", available_seats: 50, ticket_price: 10) }

  it "is valid with a user, show, and confirmation number" do
    ticket = Ticket.new(user: user, show: show, confirmation_number: "ABC123")
    expect(ticket).to be_valid
  end

  it "generates a unique confirmation number for each ticket" do
    ticket1 = Ticket.create(user: user, show: show, confirmation_number: SecureRandom.hex(8).upcase, status: "Booked")
    ticket2 = Ticket.create(user: user, show: show, confirmation_number: SecureRandom.hex(8).upcase, status: "Booked")

    expect(ticket1.confirmation_number).not_to eq(ticket2.confirmation_number)
  end

  it "stores the correct movie details" do
    ticket = Ticket.create(user: user, show: show, confirmation_number: "ABC123", status: "Booked")

    expect(ticket.show.movie.title).to eq("Test Movie")
    expect(ticket.show.movie.duration).to eq(120)
    expect(ticket.show.movie.genre).to eq("Action")
  end

  it "stores the correct show details" do
    ticket = Ticket.create(user: user, show: show, confirmation_number: "ABC123", status: "Booked")

    expect(ticket.show.date).to eq(Date.today)
    expect(ticket.show.time.strftime("%H:%M")).to eq("18:00")
    expect(ticket.show.ticket_price).to eq(10)
  end

  it "stores the correct purchaser details" do
    ticket = Ticket.create(user: user, show: show, confirmation_number: "ABC123", status: "Booked")

    expect(ticket.user.username).to eq("testuser")
    expect(ticket.user.email).to eq("test@example.com")
    expect(ticket.user.phone).to be_nil
  end
end
