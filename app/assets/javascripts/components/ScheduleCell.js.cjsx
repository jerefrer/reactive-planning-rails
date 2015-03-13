# @cjsx React.DOM

Person = require('./Person')
DragAndDrop = require('./DragAndDrop')
Helpers = require('./Helpers')

DragDropMixin = DragAndDrop.mixin
ItemTypes = DragAndDrop.ItemTypes
getDuty = Helpers.getDuty

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

getPersons = (duties, day, task) ->
  if duty = getDuty(duties, day, task)
    duty.people

module.exports = ScheduleCell
