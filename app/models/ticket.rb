class Ticket < ApplicationRecord
  belongs_to :user
  belongs_to :show

  before_destroy :restore_seat_count

  private

  def restore_seat_count
    if show.present?
      show.increment!(:available_seats)
    end
  end
end
