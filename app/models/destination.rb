class Destination < ApplicationRecord
  has_many :reviews, dependent: :destroy
  validates :name, :country, presence: true

  # GET reviews by country or city.
  scope :by_country, -> (country) do
    reviews = []
    dests = where("country ilike ?", "#{country}")
    dests.each { |d| reviews.push(d.reviews) }
    reviews
  end

  def average_rating
    if self.reviews.length > 0
      rating_sum = self.reviews.map { |r| r.rating }.reduce(:+) * 1.0
      (rating_sum/self.reviews.length).round
    else
      0
    end
  end

  # see the most popular travel destinations by number of reviews or by overall rating
  scope :by_reviews, -> {(
    select("destinations.id, destinations.name, destinations.country, count(reviews.id) as reviews_count")
    .joins(:reviews)
    .group("destinations.id")
    .order("reviews_count DESC")
  )}

  scope :by_average, -> do
    Destination.all.sort { |a,b| b.average_rating <=> a.average_rating }
  end

end
