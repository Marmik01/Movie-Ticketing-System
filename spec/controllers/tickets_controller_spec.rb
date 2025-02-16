require "rails_helper"

RSpec.describe TicketsController, type: :controller do
  let(:admin) { User.create(username: "admin1", email: "admin@example.com", password: "password", is_admin: true, credit_card_info: "1111-2222-3333-4444") }
  let(:user) { User.create(username: "user1", email: "user@example.com", password: "password", credit_card_info: "1111-2222-3333-4444") }
  let(:movie) { Movie.create(title: "Test Movie", genre: "Action", duration: 120, language: "English", rating: "PG", release_date: Date.today) }
  let(:show) { Show.create(movie: movie, date: Date.today, time: "18:00", number_of_seats_available: 50, ticket_price: 10) }
  let(:ticket) { Ticket.create(user: user, show: show, confirmation_number: "XYZ789", status: "Booked") }

  describe "DELETE #destroy" do
    context "when admin is logged in" do
      before do
        session[:user_id] = admin.id
      end

      it "deletes the ticket" do
        delete :destroy, params: { id: ticket.id }
        expect(Ticket.exists?(ticket.id)).to be_falsey
      end

      it "redirects to the tickets list with a success message" do
        delete :destroy, params: { id: ticket.id }
        expect(response).to redirect_to(tickets_path)
        expect(flash[:notice]).to eq("Ticket was successfully deleted.")
      end
    end

    context "when a regular user is logged in" do
      before do
        session[:user_id] = user.id
      end

      it "does not delete the ticket and redirects with an alert" do
        delete :destroy, params: { id: ticket.id }
        expect(Ticket.exists?(ticket.id)).to be_truthy
        expect(response).to redirect_to(tickets_path)
        expect(flash[:alert]).to eq("Unauthorized action!")
      end
    end
  end
end
