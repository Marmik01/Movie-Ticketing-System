require "application_system_test_case"

class ShowsTest < ApplicationSystemTestCase
  setup do
    @show = shows(:one)
  end

  test "visiting the index" do
    visit shows_url
    assert_selector "h1", text: "Shows"
  end

  test "should create show" do
    visit shows_url
    click_on "New show"

    fill_in "Available seats", with: @show.available_seats
    fill_in "Date", with: @show.date
    fill_in "Movie", with: @show.movie_id
    fill_in "Screen", with: @show.screen_id
    fill_in "Ticket price", with: @show.ticket_price
    fill_in "Time", with: @show.time
    click_on "Create Show"

    assert_text "Show was successfully created"
    click_on "Back"
  end

  test "should update Show" do
    visit show_url(@show)
    click_on "Edit this show", match: :first

    fill_in "Available seats", with: @show.available_seats
    fill_in "Date", with: @show.date
    fill_in "Movie", with: @show.movie_id
    fill_in "Screen", with: @show.screen_id
    fill_in "Ticket price", with: @show.ticket_price
    fill_in "Time", with: @show.time.to_s
    click_on "Update Show"

    assert_text "Show was successfully updated"
    click_on "Back"
  end

  test "should destroy Show" do
    visit show_url(@show)
    click_on "Destroy this show", match: :first

    assert_text "Show was successfully destroyed"
  end
end
