# @cjsx React.DOM

getDuty = (duties, day, task) ->
  duties.find({day: day, task: task})

module.exports =
  getDuty: getDuty
