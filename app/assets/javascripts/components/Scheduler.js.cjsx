# @cjsx React.DOM

Schedule = require('./Schedule')
PeopleList = require('./PeopleList')

window.Scheduler = React.createClass
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
