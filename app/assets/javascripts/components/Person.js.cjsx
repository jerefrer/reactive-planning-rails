# @cjsx React.DOM

DragAndDrop = require('./DragAndDrop')
DragDropMixin = DragAndDrop.mixin
ItemTypes = DragAndDrop.ItemTypes

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

module.exports = Person
