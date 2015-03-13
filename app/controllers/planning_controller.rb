class PlanningController < ApplicationController

  def show
    @days = Day.all
    @tasks = Task.all
    @people = Person.all
    @duties = Duty.all
  end

end
