`import DS from 'ember-data'`

Search = DS.Model.extend {
  boozType: DS.attr 'string'
  latitude: DS.attr 'string'
  longitude: DS.attr 'string'
  places: DS.hasMany "place", async: true
  sortedPlaces: Ember.computed.sort 'places.@each.response', (a, b) =>
    if a.get('status') == "complete"
      if a.get('response') == "in stock"
        return -1
      if a.get('response') == "not in stock" && b.get('response') == ""
        return -1
      if a.get('response') == ""
        return 1
    else
      return 1
}

`export default Search`
