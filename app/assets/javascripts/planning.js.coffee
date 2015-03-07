# @cjsx React.DOM

DragDropMixin = ReactDND.DragDropMixin
ItemTypes = { PERSON: 'person' }

k = (object) ->
  key = object.id
  key

guid = ->
  s4 = ->
    Math.floor((1 + Math.random()) * 0x10000)
      .toString(16)
      .substring(1)
  s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4()

getPersons = (duties, day, task) ->
  tasksForDay = duties[k(day)]
  tasksForDay[k(task)] if (tasksForDay)

addPersonToDuties = (duties, day, task, person) ->
  duties[k(day)] = [] unless duties[k(day)]
  persons = duties[k(day)][k(task)]
  persons = [] unless persons
  if persons.indexOf(person) == -1
    persons.push(person)
    duties[k(day)][k(task)] = persons
    duties

removePersonFromDuties = (duties, day, task, person) ->
  if duties[k(day)] && duties[k(day)][k(task)]
    persons = duties[k(day)][k(task)]
    persons.remove(person)
    duties[k(day)][k(task)] = persons
    duties

replaceDayName = (days, id, name) ->
  day = days.find({id: id})
  afterCutIncludingDay = days.splice(days.indexOf(day))
  afterCut = afterCutIncludingDay.splice(1)
  days.concat([{id: id, name: name}].concat(afterCut))

tasks = [
  {id: guid(), name: "Banque alimentaire"},
  {id: guid(), name: "Médiateur, responsable d'équipe"},
  {id: guid(), name: "Chercher pain"}
]

days = [
  {id: guid(), name: "Samedi 7 Mars 2015"},
  {id: guid(), name: "Dimanche 8 Mars 2015"},
  {id: guid(), name: "Samedi 14 Mars 2015"},
  {id: guid(), name: "Dimanche 15 Mars 2015"}
]

people = [
  {name: 'Anne'},
  {name: 'Jérémy'}
]

duties = []
duties[k(days[0])] = []
duties[k(days[0])][k(tasks[0])] = [
  people[0],
  people[1]
]

duties[k(days[2])] = []
duties[k(days[2])][k(tasks[0])] = [
  people[1]
]

Scheduler = React.createClass
  render: ->
    (
      <div className="row">
        <div className="col-md-9">
          <h2>Planning</h2>
          <Schedule tasks={@props.tasks} days={@props.days} duties={@props.duties} />
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
  handleDutyCreation:  (day, task, person) ->
    duties = addPersonToDuties(@state.duties, day, task, person)
    if person.scheduleCell
      cell = person.scheduleCell
      duties = removePersonFromDuties(duties, cell.props.day, cell.props.task, person)
    @setState({duties: duties})
  removeFromDuties:  (scheduleCell, person) ->
    duties = removePersonFromDuties(@state.duties, scheduleCell.props.day, scheduleCell.props.task, person)
    @setState({duties: duties})
  handleAddDay: (dayName) ->
    days = @state.days
    new_id = days.max('id').id + 1
    days.push({id: new_id, name: dayName})
    @setState({days: days})
  handleUpdateDayName:  (id, dayName) ->
    days = replaceDayName(@state.days, id, dayName)
    @setState({days: days})
  render: ->
    lines = []
    tasks = @props.tasks
    duties = @state.duties
    handleDutyCreation = @handleDutyCreation
    removeFromDuties = @removeFromDuties
    handleUpdateDayName = @handleUpdateDayName
    @state.days.forEach (day) ->
      lines.push(<ScheduleLine tasks={tasks} day={day} duties={duties} onPersonDrop={handleDutyCreation} removeFromDuties={removeFromDuties} handleUpdateDayName={handleUpdateDayName} />)
    <table className="table table-striped table-bordered">
      <thead>
        <ScheduleHeader tasks={tasks} />
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
    day = @props.day
    cells = []
    onPersonDrop = @props.onPersonDrop
    removeFromDuties = @props.removeFromDuties
    @props.tasks.forEach (task) ->
      cells.push(<ScheduleCell day={day} task={task} duties={duties} onPersonDrop={onPersonDrop} removeFromDuties={removeFromDuties} />)
    <tr>
      <td><DayName day={day} onUpdateDayName={@props.handleUpdateDayName} /></td>
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
    @props.onUpdateDayName(@props.day.id, dayName)
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
  render: ->
    people = @props.people.map (person) ->
      <li><Person person={person}/></li>
    <ul className="list-unstyled">{people}</ul>

ready = ->
  React.render(
    <Scheduler tasks={tasks} days={days} duties={duties} people={people}/>,
    document.getElementById('planning'))

$(document).ready(ready)
$(document).on('page:load', ready)
