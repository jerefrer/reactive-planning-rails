# @cjsx React.DOM

ScheduleCell = require('./ScheduleCell')
DayForm = require('./DayForm')

ScheduleLine = React.createClass
  render: ->
    cells = []
    @props.tasks.forEach (task) =>
      cells.push(<ScheduleCell day={@props.day} task={task} duties={@props.duties} onPersonDrop={@props.onPersonDrop} removeFromDuties={@props.removeFromDuties} />)
    <tr>
      <td><DayName day={@props.day} onUpdateDayName={@props.handleUpdateDayName} /></td>
      {cells}
    </tr>

DayName = React.createClass
  getInitialState: ->
    formIsVisible: false
  showForm: ->
    @setState
      formIsVisible: true
  hideForm: ->
    @setState
      formIsVisible: false
  updateDayName: (dayName) ->
    @hideForm()
    @props.onUpdateDayName(@props.day, dayName)
  render: ->
    if (@state.formIsVisible)
      <DayForm onSubmit={@updateDayName} onCancel={@hideForm} />
    else
      <strong onClick={@showForm} title="Cliquez pour modifier">{@props.day.name}</strong>

module.exports = ScheduleLine
