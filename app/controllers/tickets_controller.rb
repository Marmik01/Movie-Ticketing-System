class TicketsController < ApplicationController
  before_action :require_admin, only: [:index]
  before_action :set_ticket, only: %i[ show  update destroy ]
  before_action :set_show, only: [:create]

  # GET /tickets or /tickets.json
  def index
    if current_user.is_admin
      @tickets = Ticket.includes(:show, { show: :movie }, :user).all
    else
      @tickets = current_user.tickets.includes(:show, { show: :movie })
    end

  end

  # GET /tickets/1 or /tickets/1.json
  def show
  end

  # POST /tickets or /tickets.json
  def create
    if @show.available_seats > 0
      @ticket = @show.tickets.new(
        user: current_user,
        confirmation_number: generate_unique_confirmation_number,
        status: "Booked"
      )

      respond_to do |format|
        if @ticket.save
          @show.reduce_seat_count!
          format.html { redirect_to movie_show_ticket_path(@show.movie, @show, @ticket), notice: "Ticket purchased successfully!" }
          format.json { render :show, status: :created, location: movie_show_ticket_url(@show.movie, @show, @ticket) }
        else
          format.html { redirect_to show_path(@show), alert: "Error purchasing ticket." }
          format.json { render json: @ticket.errors, status: :unprocessable_entity }
        end
      end
    else
      redirect_to show_path(@show), alert: "No available seats left."
    end
  end

  # PATCH/PUT /tickets/1 or /tickets/1.json
  def update
    respond_to do |format|
      if ticket_params[:status] == "Cancelled" && @ticket.status != "Cancelled"
        @ticket.update(status: "Cancelled")
        @ticket.show.increase_seat_count!
        format.html { redirect_to movie_show_ticket_path(@ticket.show.movie, @ticket.show, @ticket), notice: "Ticket was successfully updated." }
        format.json { render :show, status: :ok, location: movie_show_ticket_path(@ticket.show.movie, @ticket.show, @ticket) }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tickets/1 or /tickets/1.json
  def destroy
    @ticket.destroy!

    respond_to do |format|
      format.html { redirect_to tickets_path, status: :see_other, notice: "Ticket was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

    def set_show
      @show = Show.find(params[:show_id])
    end

    def generate_unique_confirmation_number
      loop do
        confirmation_number = SecureRandom.hex(8).upcase
        break confirmation_number unless Ticket.exists?(confirmation_number: confirmation_number)
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_ticket
      @ticket = Ticket.find(params.expect(:id))
    end

    def require_admin
      unless current_user
        redirect_to root_path, alert: "Unauthorized Access!"
      end
    end
    

    # Only allow a list of trusted parameters through.
    def ticket_params
      params.expect(ticket: [:status])
    end
end
