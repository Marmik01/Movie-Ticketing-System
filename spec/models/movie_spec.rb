require 'rails_helper'

RSpec.describe Movie, type: :model do
  subject { 
    described_class.new(
      title: "Inception",
      genre: "Sci-Fi",
      duration: 148,
      language: "English",
      rating: "PG-13",
      release_date: Date.today
    )
  }

  # Validations
  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  it "is not valid without a title" do
    subject.title = nil
    expect(subject).not_to be_valid
  end

  it "is not valid without a genre" do
    subject.genre = nil
    expect(subject).not_to be_valid
  end

  it "is not valid without a duration" do
    subject.duration = nil
    expect(subject).not_to be_valid
  end

  it "is not valid without a language" do
    subject.language = nil
    expect(subject).not_to be_valid
  end

  it "is not valid without a rating" do
    subject.rating = nil
    expect(subject).not_to be_valid
  end

  it "is not valid without a release date" do
    subject.release_date = nil
    expect(subject).not_to be_valid
  end

  it "is not valid with a duplicate title" do
    described_class.create!(
      title: "Inception", 
      genre: "Sci-Fi", 
      duration: 148, 
      language: "English", 
      rating: "PG-13", 
      release_date: Date.today
    )
    expect(subject).not_to be_valid
  end
end
