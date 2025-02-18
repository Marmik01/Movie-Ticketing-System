class Movie < ApplicationRecord
    has_many :shows, dependent: :destroy

    validates :title, presence: true, uniqueness: { case_sensitive: false } # Ensures unique titles
    validates :genre, :duration, :language, :rating, :release_date, presence: true
end
