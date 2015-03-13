# @cjsx React.DOM

DayForm = require('./DayForm')

AddDayCell = React.createClass
  getInitialState: ->
    formIsVisible: false
  showForm: ->
    @setState
      formIsVisible: true
  hideForm: ->
    @setState
      formIsVisible: false
  addDay: (dayName) ->
    @hideForm()
    @props.onAddDay(dayName)
  render: ->
    if (@state.formIsVisible)
      <DayForm onSubmit={@addDay} onCancel={@hideForm} />
    else
      <a href="#" onClick={@showForm}>Ajouter un jour</a>

module.exports = AddDayCell
