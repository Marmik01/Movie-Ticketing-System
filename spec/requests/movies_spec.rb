require 'rails_helper'

RSpec.describe "Movies", type: :request do
  let!(:admin) { User.create!(username: "admin", email: "admin@example.com", password: "password", is_admin: true) }
  let!(:user) { User.create!(username: "normal_user", email: "user@example.com", password: "password", is_admin: false, credit_card_info: "1111-1111-1111-1111") }
  let!(:movie) { Movie.create!(title: "Inception", genre: "Sci-Fi", duration: 148, language: "English", rating: "PG-13", release_date: Date.today) }

  let(:valid_attributes) {
    { title: "Interstellar", genre: "Sci-Fi", duration: 169, language: "English", rating: "PG-13", release_date: Date.today }
  }

  let(:invalid_attributes) {
    { title: nil, genre: "Sci-Fi", duration: 169, language: "English", rating: "PG-13", release_date: Date.today }
  }

  # ✅ Authenticate users before each test
  before do
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(admin) # Default to admin
  end

  # ✅ Test public movie viewing
  describe "GET /movies" do
    it "allows normal users to view movies" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      get movies_path
      expect(response).to have_http_status(:ok)
    end

    it "allows unauthenticated users to view movies" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
      get movies_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /movies/:id" do
    it "allows normal users to view a movie" do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
      get movie_path(movie)
      expect(response).to have_http_status(:ok)
    end

    it "if movie does not exist" do
      get movie_path(id: 9999) # Non-existent movie
      expect(response).to redirect_to(movies_path)
      expect(flash[:alert]).to eq("Movie not found or not yet released.")
    end
  end

  # ✅ Admin tests
  describe "Admin Actions" do
    describe "POST /movies" do
      context "with valid parameters" do
        it "creates a new Movie" do
          expect {
            post movies_path, params: { movie: valid_attributes }
          }.to change(Movie, :count).by(1)
        end

        it "redirects to the movies index" do
          post movies_path, params: { movie: valid_attributes }
          expect(response).to redirect_to(movies_path)
        end
      end

      context "with invalid parameters" do
        it "does not create a new Movie" do
          expect {
            post movies_path, params: { movie: invalid_attributes }
          }.not_to change(Movie, :count)
        end

        it "renders an error response" do
          post movies_path, params: { movie: invalid_attributes }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "PATCH /movies/:id" do
      context "with valid parameters" do
        let(:new_attributes) { { title: "Interstellar" } }

        it "updates the requested movie" do
          patch movie_path(movie), params: { movie: new_attributes }
          movie.reload
          expect(movie.title).to eq("Interstellar")
        end

        it "redirects to the movie" do
          patch movie_path(movie), params: { movie: new_attributes }
          expect(response).to redirect_to(movie)
        end
      end

      context "with duplicate title" do
        let!(:duplicate_movie) { Movie.create!(title: "Interstellar", genre: "Sci-Fi", duration: 169, language: "English", rating: "PG-13", release_date: Date.today) }

        it "does not update to an existing movie title" do
          patch movie_path(movie), params: { movie: { title: "Interstellar" } }
          movie.reload
          expect(movie.title).not_to eq("Interstellar")
        end

        it "renders an error response" do
          patch movie_path(movie), params: { movie: { title: "Interstellar" } }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    describe "DELETE /movies/:id" do
      it "destroys the requested movie" do
        expect {
          delete movie_path(movie)
        }.to change(Movie, :count).by(-1)
      end

      it "redirects to the movies list" do
        delete movie_path(movie)
        expect(response).to redirect_to(movies_path)
      end
    end
  end

  # ✅ Normal User Restrictions
  describe "Restricted Actions for Normal Users" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    end

    it "prevents normal users from creating movies" do
      post movies_path, params: { movie: valid_attributes }
      expect(response).to redirect_to(movies_path)
      expect(flash[:alert]).to eq("Access denied!")
    end

    it "prevents normal users from editing movies" do
      patch movie_path(movie), params: { movie: { title: "Interstellar" } }
      expect(response).to redirect_to(movies_path)
      expect(flash[:alert]).to eq("Access denied!")
    end

    it "prevents normal users from deleting movies" do
      delete movie_path(movie)
      expect(response).to redirect_to(movies_path)
      expect(flash[:alert]).to eq("Access denied!")
    end
  end

  # ✅ Unauthorized User Tests
  describe "Unauthorized User Access" do
    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(nil)
    end

    it "prevents unauthenticated users from creating movies" do
      post movies_path, params: { movie: valid_attributes }
      expect(response).to redirect_to(movies_path)
      expect(flash[:alert]).to eq("Access denied!")
    end

    it "prevents unauthenticated users from editing movies" do
      patch movie_path(movie), params: { movie: { title: "Interstellar" } }
      expect(response).to redirect_to(movies_path)
      expect(flash[:alert]).to eq("Access denied!")
    end

    it "prevents unauthenticated users from deleting movies" do
      delete movie_path(movie)
      expect(response).to redirect_to(movies_path)
      expect(flash[:alert]).to eq("Access denied!")
    end
  end
end
