# @cjsx React.DOM

Schedule = require('./Schedule')
PeopleList = require('./PeopleList')

Scheduler = React.createClass
  render: ->
    (
      <div className="row">
        <div className="col-md-9">
          <h2>Planning</h2>
          <Schedule tasks={@props.tasks} days={@props.days} duties={@props.duties} days_url={@props.days_url} duties_url={@props.duties_url} />
        </div>
        <div className="col-md-3">
          <h2>Bénévoles</h2>
          <PeopleList people={@props.people} />
        </div>
      </div>
    )

ready = ->
  days = $('#planning').data('days')
  tasks = $('#planning').data('tasks')
  people = $('#planning').data('people')
  duties = $('#planning').data('duties')
  days_url = $('#planning').data('days-url')
  duties_url = $('#planning').data('duties-url')

  React.render(
    <Scheduler tasks={tasks} days={days} duties={duties} people={people} days_url={days_url} duties_url={duties_url} />,
    document.getElementById('planning'))

$(document).ready(ready)
$(document).on('page:load', ready)
