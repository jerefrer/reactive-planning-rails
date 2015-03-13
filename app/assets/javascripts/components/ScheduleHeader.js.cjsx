# @cjsx React.DOM

ScheduleHeader = React.createClass
  render: ->
    tasks = []
    @props.tasks.forEach (task) ->
      tasks.push(<td><strong>{task.name}</strong></td>)
    <tr>
      <td></td>
      {tasks}
    </tr>

module.exports = ScheduleHeader
