class BookingsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:edit, :update, :new]

  def new
    @car = Car.find(params[:car_id])
    @booking = Booking.new
  end

  def create
    @car = Car.find(params[:car_id])
    @booking = Booking.new(booking_params)
    @booking.car = @car
    @booking.user = current_user
    @booking.price = (@booking.date_to - @booking.date_from).to_i * @car.price_per_day
    if @booking.save
      redirect_to dashboard_path(current_user)
    else
      render "cars#show"
    end
  end

  def edit
    @booking = Booking.find(params[:id])
  end

  def update
    @booking = Booking.find(params[:id])
    @booking.update(booking_params)
    redirect_to dashboard_path(current_user)
  end

  def dashboard
    @bookings = Booking.where(user_id: current_user)
    @reviews = Review.where(booking_id: @bookings)
    @cars = Car.where(user_id: current_user)
    # This is a function to get the total profit
    @number_of_days = 1
    @total_profit = 0
    @bookings.each do |booking|
      @total_profit = @total_profit + booking.price
      @number_of_days = (booking.date_to - booking.date_from).to_i
    end
    @number_of_reviews = 0
    @reviews.each do |review|
      @number_of_reviews += 1
    end
  end

  def destroy
    @booking = Booking.find(params[:id])
    @booking.destroy
    respond_to do |format|
      format.html {redirect_to dashboard_path}
      format.json { head :no_content }
    end
  end

  private

  def booking_params
    params.require(:booking).permit(:user_id, :car_id, :date_from, :date_to)
  end
end
