class ShowsController < ApplicationController
  before_action :set_show, only: %i[ show edit update destroy ]
  before_action :set_movie, only: [:index, :new, :create]
  before_action :require_admin, only: [:new, :create, :edit, :update, :destroy]


  # GET /shows or /shows.json
  def index
    if current_user&.is_admin
      @shows = @movie.shows # Admins see all shows
    else
      if @movie.release_date > Date.today
        flash[:alert] = "You cannot view shows for an unreleased movie."
        redirect_to movies_path and return
      end

      @shows = @movie.shows.where("available_seats > 0") # Users see only available shows for released movies
    end
  end

  # GET /shows/1 or /shows/1.json
  def show
    unless current_user&.is_admin || (@show.available_seats > 0 && @show.movie.release_date <= Date.today)
      flash[:alert] = "This show is not available."
      redirect_to movies_path
    end
  end

  # GET /shows/new
  def new
    @show = @movie.shows.new
  end

  # GET /shows/1/edit
  def edit
  end

  # POST /shows or /shows.json
  def create
    @show = @movie.shows.new(show_params)

    respond_to do |format|
      if @show.save
        format.html { redirect_to movie_shows_path(@movie), notice: "Show was successfully created." }
        format.json { render :show, status: :created, location: @show }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @show.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /shows/1 or /shows/1.json
  def update
    respond_to do |format|
      if @show.update(show_params)
        format.html { redirect_to movie_shows_path(@show.movie), notice: "Show was successfully updated." }
        format.json { render :show, status: :ok, location: @show }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @show.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /shows/1 or /shows/1.json
  def destroy
    movie = @show.movie
    @show.destroy!

    respond_to do |format|
      format.html { redirect_to movie_shows_path(movie), status: :see_other, notice: "Show was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    def set_movie
      @movie = Movie.find_by(id: params[:movie_id])
      if @movie.nil? || (!current_user&.is_admin && @movie.release_date > Date.today)
        flash[:alert] = "Movie not found"
        redirect_to movies_path and return
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_show
      @show = Show.find(params[:id])
      @movie = @show.movie  # Ensure @movie is set
      @show = Show.find_by(id: params[:id])
      if @show.nil? || (!current_user&.is_admin && @show.movie.release_date > Date.today)
        flash[:alert] = "Show not available or movie not released."
        redirect_to movies_path
      end
    end

  #only admin and create, update and destroy the shows
    def require_admin
      unless current_user&.is_admin
        flash[:alert] = "Access denied! Only admins can manage shows."
        redirect_to movies_path
      end
    end

    # Only allow a list of trusted parameters through.
    def show_params
      params.expect(show: [:screen_id, :date, :time, :ticket_price ])
    end
end
