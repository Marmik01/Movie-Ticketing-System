class Show < ApplicationRecord
  belongs_to :movie
  belongs_to :screen
  has_many :tickets, dependent: :destroy 

  validates :movie_id, presence: true
  validates :screen_id, presence: true
  validates :date, presence: true
  validates :time, presence: true
  validates :available_seats, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :ticket_price, numericality: { greater_than_or_equal_to: 0 }

  def reduce_seat_count!
    update_column(:available_seats, available_seats - 1)
  end
  def increase_seat_count!
    update_column(:available_seats, available_seats + 1)
  end

  # Prevent changing movie_id after creation
  before_update :prevent_movie_change
  
  # Ensure show date is not before the movie's release date
  validate :date_cannot_be_before_movie_release

  # Set available seats based on screen capacity before saving
  before_validation :set_seat_capacity
  private

  def prevent_movie_change
    if movie_id_changed?
      errors.add(:movie_id, "cannot be changed after the show is created.")
      throw :abort
    end
  end

  def date_cannot_be_before_movie_release
    if movie && date.present? && date < movie.release_date
      errors.add(:date, "cannot be before the movie release date (#{movie.release_date}).")
    end
  end

  def set_seat_capacity
    self.available_seats = screen.capacity if screen.present?
  end
end
