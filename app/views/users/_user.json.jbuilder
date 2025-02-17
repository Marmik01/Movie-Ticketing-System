json.extract! user, :id, :username, :name, :email, :password, :phone, :address, :credit_card_info, :is_admin, :created_at, :updated_at
json.url user_url(user, format: :json)
