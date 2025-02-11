class User < ApplicationRecord
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }
  validates :credit_card_info, presence: true, format: { with: /\A\d{4}-\d{4}-\d{4}-\d{4}\z/, message: "must be in format XXXX-XXXX-XXXX-XXXX" }
end
