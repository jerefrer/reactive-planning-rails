# @cjsx React.DOM

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

module.exports = DayForm
