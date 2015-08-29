`import Ember from 'ember'`

MainController = Ember.Controller.extend
  latitude: null
  longitude: null
  boozType: null
  placesCount: 0
  currentRadius: 200
  latLng: null
  map: null
  placesService: null
  search: null
  handlerApi: "https://booz-club-new-back-production.herokuapp.com/search"

  getPlacesService: (context) ->
    unless context.get('placesService')
      context.set 'placesService', new google.maps.places.PlacesService(context.getMap(context))
    @get('placesService')

  getLatLng: (context) ->
    unless context.get('latLng')
      context.set 'latLng', new google.maps.LatLng(context.get('latitude'), context.get('longitude'))
    context.get('latLng')

  getMap: (context) ->
    unless context.get('map')
      context.set 'map', new google.maps.Map($('.map')[0], {center: context.getLatLng(context), zoom: 15})
    context.get('map')

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

  placesSearchComplete: ->
    $.ajax
      url: @get('handlerApi')
      data: {searchId: @get('search').id}
      method: "post"
      success: (result) =>
        @transitionTo 'search', @get('search').id
      fail: (result) ->
        alert "shit, something went wrong"

  createAllPlaces: (places, currentIndex) ->
    nextIndex = currentIndex + 5
    currentBatch = places.slice(currentIndex, nextIndex)
    for place in currentBatch
      @getPlacesService(this).getDetails {placeId: place.place_id}, (place, status) =>
        @store.createRecord("place", {
          search: @get('search')
          name: place.name
          status: "created"
          response: null
          # phone: place.formatted_phone_number
          phone: "(707) 849-6085"
          address: place.formatted_address
        }).save().then (newPlace) =>
          @get('search').get('places').then (places) =>
            places.pushObject newPlace
            @get('search').save()
            @set 'placesCount', @get('placesCount') - 1
            console.log @get("placesCount")
            @placesSearchComplete() if @get('placesCount') == 0
    setTimeout =>
      @createAllPlaces(places, nextIndex) if places[nextIndex] != undefined
    , 2000

  checkDensity: (results) ->
    console.log @get('placesCount')
    if @get('currentRadius') > 4828 && @get('placesCount') < 5
      # Not enough places
    # else if @get('placesCount') < 12
    else if @get('placesCount') < 2
      # found X places, looking for more
      setTimeout =>
        @set 'currentRadius', @get('currentRadius') + 200
        @nearbySearch()
      , 330
    else
      # X places found. We're now calling them all to look for Y!
      @createAllPlaces(results, 0)

  nearbyRequestData: ->
    location: @get('getLatLng')(this)
    radius: @get('currentRadius')
    open_now: true
    types: ['liquor_store']

  nearbySearch: ->
    @getPlacesService(this).nearbySearch @nearbyRequestData(), (results) =>
      console.log "1"
      @set "placesCount", results.length
      @checkDensity results

  actions:
    beginSearch: ->
      newSearch = @store.createRecord 'search', {
        boozType: @get('boozType')
        latitude: @get('latitude')
        longitude: @get('longitude')
      }

      newSearch.save().then (search) =>
        @set 'search', search
        @nearbySearch()

`export default MainController`
