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
  classes: ->
    cx = React.addons.classSet
    classes = cx
      'alert': true
      'alert-info': true
      'text-center': true
      disabled: @props.person.disabled
  render: ->
    <div className={@classes()}
         {...@dragSourceFor(ItemTypes.PERSON)} >
      {@props.person.name}
    </div>

module.exports = Person
