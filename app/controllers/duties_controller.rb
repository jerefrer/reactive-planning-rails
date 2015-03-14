class DutiesController < ApplicationController

  def create
    set_day_task_person_and_duty
    @duty ||= Duty.create(day: @day, task: @task)
    unless @duty.people.include?(@person)
      @duty.people += [@person]
    end
    render json: Duty.all.to_json
  end

  def delete
    set_day_task_person_and_duty
    if @duty
      @duty.people -= [@person]
    end
    render json: Duty.all.to_json
  end

private

  def set_day_task_person_and_duty
    @day = Day.find(params[:day_id])
    @task = Task.find(params[:task_id])
    @person = Person.find(params[:person_id])
    @duty = Duty.where('day._id' => @day.id).where('task._id' => @task.id).first
  end

end
