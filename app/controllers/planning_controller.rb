class PlanningController < ApplicationController

  def show
    @days = Day.all.to_json
    @tasks = Task.all.to_json
    @people = Person.all.to_json
    @duties = Duty.all.to_json
  end

end
