class DutiesController < ApplicationController

  def create
    day = Day.find(params[:day_id])
    task = Task.find(params[:task_id])
    person = Person.find(params[:person_id])
    duty = Duty.where('day._id' => day.id).where('task._id' => task.id).first
    duty ||= Duty.create(day: day, task: task)
    unless duty.people.include?(person)
      duty.people += [person]
    end
    render nothing: true
  end

end
