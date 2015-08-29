`import DS from 'ember-data'`

Search = DS.Model.extend {
  boozType: DS.attr 'string'
  latitude: DS.attr 'string'
  longitude: DS.attr 'string'
  places: DS.hasMany "place", async: true
}

`export default Search`
