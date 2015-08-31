`import DS from 'ember-data'`

Search = DS.Model.extend {
  boozType: DS.attr 'string'
  latitude: DS.attr 'string'
  longitude: DS.attr 'string'
  places: DS.hasMany "place", async: true
  sortedPlaces: Ember.computed.sort 'places.@each.response', (a, b) =>
      if a.get('response') == "in stock" && b.get('response') == "not in stock"
        return -1
      if a.get('response') == "in stock" && b.get('response') == undefined
        console.log a.get('id')
        return -1
      if a.get('response') == "not in stock" && b.get('response') == undefined
        return 1
      if a.get('response') == "not in stock" && b.get('response') == "in stock"
        return 1
      if a.get('response') == undefined && b.get('response') == "in stock"
        return 1
      if a.get('response') == undefined && b.get('response') == "not in stock"
        return 1
      if a.get('response') == b.get('response')
        return 0
      else
        1
}

`export default Search`
