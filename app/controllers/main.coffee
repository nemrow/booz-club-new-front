`import Ember from 'ember'`

MainController = Ember.Controller.extend
  latitude: null
  longitude: null

  locationFound: (->
    @get('latitude') && @get('longitude')
  ).property('latitude', 'longitude')

  init: ->
    this._super()

    # Begin geo location inquiry
    @get('geolocation').start()

    # You can use event handlers
    @get('geolocation').on 'change', (geoposition) =>
      @set 'latitude', geoposition.coords.latitude
      @set 'longitude', geoposition.coords.longitude

    @get('geolocation').on 'error', ->
      console.log("SOME ERR");

    # Or you can simply do like that
    this.get('geolocation').getGeoposition().then (geoposition) =>
      @set 'latitude', geoposition.coords.latitude
      @set 'longitude', geoposition.coords.longitude

  actions:
    beginSearch: ->
      newSearch = @store.createRecord 'search', {
        boozType: @get('boozType')
      }
      newSearch.save().then (search) =>
        @transitionTo 'search', search.id


`export default MainController`
