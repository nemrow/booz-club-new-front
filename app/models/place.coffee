`import DS from 'ember-data'`

Place = DS.Model.extend {
  name: DS.attr "string"
  search: DS.belongsTo "search", async: true
  status: DS.attr "string"
  phone: DS.attr "string"
  response: DS.attr "string"
  address: DS.attr "string"
}

`export default Place`
