class DaysController < ApplicationController

  def index
    days = Day.all
    render @days
  end

end
