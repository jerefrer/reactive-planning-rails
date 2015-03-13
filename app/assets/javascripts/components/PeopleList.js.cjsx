# @cjsx React.DOM

Person = require('./Person')

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

module.exports = PeopleList
