class User < ApplicationRecord
  has_many :tickets, dependent: :destroy

  before_destroy :restore_seat_count


  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, presence: true, length: { minimum: 6 }
  validates :credit_card_info, presence: true, format: { with: /\A\d{4}-\d{4}-\d{4}-\d{4}\z/, message: "must be in format XXXX-XXXX-XXXX-XXXX" }, unless: -> { is_admin? }

  private

  def restore_seat_count
    tickets.includes(:show).each do |ticket|
      if ticket.show.present?  # Ensure show exists
        ticket.show.increment!(:available_seats)
      end
    end
  end


end
