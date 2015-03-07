class DaysController < ApplicationController

  def create
    day = Day.create(name: params[:name])
    render json: day.to_json
  end

end
