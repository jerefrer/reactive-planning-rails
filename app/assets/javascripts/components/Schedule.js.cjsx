# @cjsx React.DOM

ScheduleHeader = require('./ScheduleHeader')
ScheduleLine = require('./ScheduleLine')
AddDayCell = require('./AddDayCell')
Helpers = require('./Helpers')

getDuty = Helpers.getDuty

Schedule = React.createClass
  getInitialState: ->
    days: @props.days,
    duties: @props.duties
  addPersonToDuties: (duties, day, task, person) ->
    if duty = getDuty(duties, day, task)
      unless duty.people.find({_id: {$oid: person._id.$oid}})
        duty.people.push(person)
    else
      duties.push({day: day, task: task, people: [person]})
    duties
  addPersonToDutiesOnServer: (day, task, person) ->
    $.ajax
      type: 'POST'
      url: @props.duties_url
      dataType: 'json'
      data:
        day_id: id(day),
        task_id: id(task),
        person_id: id(person)
  handleDutyCreation: (day, task, person) ->
    duties = @addPersonToDuties(@state.duties, day, task, person)
    if person.scheduleCell
      cell = person.scheduleCell
      duties = @removePersonFromDuties(duties, cell.props.day, cell.props.task, person)
    @setState
      duties: duties
    @addPersonToDutiesOnServer(day, task, person)
  removePersonFromDuties: (duties, day, task, person) ->
    if duty = getDuty(duties, day, task)
      duty.people.remove(person)
    duties
  removePersonFromDutiesOnServer: (day, task, person) ->
    $.ajax
      type: 'POST'
      url: @props.duties_url
      dataType: 'json'
      data:
        day_id: id(day),
        task_id: id(task),
        person_id: id(person)
  handleDutyRemoval: (scheduleCell, person) ->
    duties = @removePersonFromDuties(@state.duties, scheduleCell.props.day, scheduleCell.props.task, person)
    @setState({duties: duties})
    @removePersonFromDutiesOnServer(scheduleCell.props.day, scheduleCell.props.task, person)
  handleAddDay: (dayName) ->
    $.ajax
      type: 'POST'
      url: @props.days_url
      dataType: 'json'
      data:
        name: dayName
      success: (day) =>
        days = @state.days
        days.push(day)
        @setState
          days: days
  handleUpdateDayName: (day, dayName) ->
    days = replaceDayNameInDays(@state.days, day, dayName)
    duties = replaceDayNameInDuties(@state.duties, day, dayName)
    @setState
      days: days
      duties: duties
  render: ->
    lines = []
    @state.days.forEach (day) =>
      lines.push(<ScheduleLine tasks={@props.tasks} day={day} duties={@props.duties} onPersonDrop={@handleDutyCreation} removeFromDuties={@handleDutyRemoval} handleUpdateDayName={@handleUpdateDayName} />)
    <table className="table table-striped table-bordered">
      <thead>
        <ScheduleHeader tasks={@props.tasks} />
      </thead>
      <tbody>
        {lines}
        <tr>
          <td><AddDayCell onAddDay={@handleAddDay} /></td>
          <td colSpan="5000"></td>
        </tr>
      </tbody>
    </table>

id = (object) ->
  object._id.$oid

replaceDayNameInDays = (days, oldDay, dayName) ->
  newDay = clone(oldDay)
  newDay.name = dayName
  afterCutIncludingDay = days.splice(days.indexOf(oldDay))
  afterCut = afterCutIncludingDay.splice(1)
  days.concat([newDay].concat(afterCut))

replaceDayNameInDuties = (duties, oldDay, dayName) ->
  newDay = clone(oldDay)
  newDay.name = dayName
  duties.findAll({day: oldDay}).forEach (duty) ->
    duty.day = newDay
  duties

clone = (object) ->
  jQuery.extend(true, {}, object)

module.exports = Schedule
