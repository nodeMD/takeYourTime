class StoperController < ApplicationController
  before_action :require_user

  def show
    @stoper = current_user.stoper || Stoper.create(user: current_user)
    render json: {
      time: @stoper.time,
      running: @stoper.running?
    }
  end

  def start
    @stoper = current_user.stoper || Stoper.create(user: current_user)
    @stoper.start
    render json: {status: "started"}
  end

  def stop
    @stoper = current_user.stoper
    @stoper&.stop
    render json: {status: "stopped"}
  end

  def continue
    @stoper = current_user.stoper
    @stoper&.continue
    render json: {status: "continued"}
  end

  def reset
    @stoper = current_user.stoper
    @stoper&.reset
    render json: {status: "reset"}
  end
end
