# @cjsx React.DOM

DragDropMixin = ReactDND.DragDropMixin
ItemTypes = { PERSON: 'person' }

id = (object) ->
  object._id.$oid

randomId = ->
  Math.random().toString(36).substr(2, 16)

clone = (object) ->
  jQuery.extend(true, {}, object)

getDuty = (duties, day, task) ->
  duties.find({day: day, task: task})

getPersons = (duties, day, task) ->
  if duty = getDuty(duties, day, task)
    duty.people

removePersonFromDuties = (duties, day, task, person) ->
  if duty = getDuty(duties, day, task)
    duty.people.remove(person)
  duties

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


Schedule = React.createClass
  getInitialState: ->
    days: @props.days,
    duties: @props.duties
  addPersonToDuties: (duties, day, task, person) ->
    if duty = getDuty(duties, day, task)
      unless duty.people.find(person)
        duty.people.push(person)
    else
      duties.push({day: day, task: task, people: [person]})
    duties
  addPersonToDutiesOnServer: (day, task, person) ->
    $.ajax
      type: "POST"
      url: @props.duties_url
      dataType: 'json'
      data:
        day_id: id(day),
        task_id: id(task),
        person_id: id(person)
  handleDutyCreation:  (day, task, person) ->
    duties = @addPersonToDuties(@state.duties, day, task, person)
    if person.scheduleCell
      cell = person.scheduleCell
      duties = removePersonFromDuties(duties, cell.props.day, cell.props.task, person)
    @setState
      duties: duties
    @addPersonToDutiesOnServer(day, task, person)
  removeFromDuties:  (scheduleCell, person) ->
    duties = removePersonFromDuties(@state.duties, scheduleCell.props.day, scheduleCell.props.task, person)
    @setState({duties: duties})
  handleAddDay: (dayName) ->
    $.ajax
      type: "POST"
      url: @props.days_url
      dataType: 'json'
      data:
        name: dayName
      success: (day) =>
        days = @state.days
        days.push(day)
        @setState
          days: days
  handleUpdateDayName:  (day, dayName) ->
    days = replaceDayNameInDays(@state.days, day, dayName)
    duties = replaceDayNameInDuties(@state.duties, day, dayName)
    @setState
      days: days
      duties: duties
  render: ->
    lines = []
    @state.days.forEach (day) =>
      lines.push(<ScheduleLine tasks={@props.tasks} day={day} duties={@props.duties} onPersonDrop={@handleDutyCreation} removeFromDuties={@removeFromDuties} handleUpdateDayName={@handleUpdateDayName} />)
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


ScheduleHeader = React.createClass
  render: ->
    tasks = []
    @props.tasks.forEach (task) ->
      tasks.push(<td><strong>{task.name}</strong></td>)
    <tr>
      <td></td>
      {tasks}
    </tr>

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


ScheduleCell = React.createClass
  handlePersonDrop: (person) ->
    @props.onPersonDrop(@props.day, @props.task, person)
  removePerson: (person) ->
    @props.removeFromDuties(@, person)
  mixins: [DragDropMixin]
  statics:
    configureDragDrop: (register) ->
      register(ItemTypes.PERSON, {
        dropTarget:
          acceptDrop: (component, person) ->
            component.handlePersonDrop(person)
      })
  render: ->
    self = @
    peopleList = getPersons(@props.duties, @props.day, @props.task)
    people = ''
    removePerson = @removePerson
    if (peopleList)
      people = peopleList.map (person) ->
        <Person person={person} scheduleCell={self} onThrowAway={removePerson}/>
    dropState = @getDropState(ItemTypes.PERSON)
    className = ''
    className = 'hover' if dropState.isHovering
    <td {...this.dropTargetFor(ItemTypes.PERSON)} className={className}>{people}</td>

Person = React.createClass
  mixins: [DragDropMixin]
  statics:
    configureDragDrop: (register) ->
      register(ItemTypes.PERSON, {
        dragSource:
          beginDrag: (component) ->
            person = component.props.person
            person.scheduleCell = component.props.scheduleCell # DND only passed the JS object, not the React one, so we have to explicitly set scheduleCell on the JS object
            {
              item: person
            }
          endDrag: (component, effect) ->
            if (!effect) # If throwing away
              component.props.onThrowAway(component.props.person)
      })
  render: ->
    <div className="alert alert-info text-center"
         {...this.dragSourceFor(ItemTypes.PERSON)} >
      {this.props.person.name}
    </div>

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

DayForm = React.createClass
  componentDidMount: ->
    @refs.dayName.getDOMNode().focus()
  handleSubmit: (e) ->
    e.preventDefault()
    dayName = @refs.dayName.getDOMNode().value.trim()
    @props.onSubmit(dayName)
    @refs.dayName.getDOMNode().value = ''
  render: ->
    <div>
      <form onSubmit={@handleSubmit}>
        <input className="form-control" ref="dayName" />
      </form>
      <a href="#" onClick={@props.onCancel} className="pull-right">Annuler</a>
    </div>

PeopleList = React.createClass
  getInitialState: ->
    people: @props.people
  filterBySearchTerm: (term) ->
    @setState
      people: @props.people.findAll
        name: new RegExp(term, 'i')
  render: ->
    people = @state.people.map (person) ->
      <li><Person person={person}/></li>
    <div>
      <PeopleFilters onChange={@filterBySearchTerm} />
      <ul className="list-unstyled">{people}</ul>
    </div>

PeopleFilters = React.createClass
  handleChange: ->
    @props.onChange @refs.name.getDOMNode().value.trim()
  render: ->
    <div className="form-group form-inline">
      <label className="control-label">Nom</label>
      <input type="text" ref="name" onChange={@handleChange} className="form-control" />
    </div>

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
