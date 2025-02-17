json.extract! ticket, :id, :user_id, :show_id, :confirmation_number, :status, :created_at, :updated_at
json.url ticket_url(ticket, format: :json)
