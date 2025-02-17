json.extract! show, :id, :movie_id, :screen_id, :date, :time, :available_seats, :ticket_price, :created_at, :updated_at
json.url show_url(show, format: :json)
