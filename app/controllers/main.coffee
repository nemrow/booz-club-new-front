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
  searching: false
  userCountry: null
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

  isInUnitedStates: (->
    if @get('userCountry')
      @get('userCountry') == "United States"
  ).property('locationFound', 'userCountry')

  locationFound: (->
    @get('latitude') && @get('longitude') && @get('userCountry') != null
  ).property('latitude', 'longitude', 'userCountry')

  setLocation: (geoposition) ->
    @set 'latitude', geoposition.coords.latitude
    @set 'longitude', geoposition.coords.longitude
    geocoder = new google.maps.Geocoder()
    latlng = {lat: @get('latitude'), lng: @get('longitude')}
    geocoder.geocode {location: latlng}, (results, status) =>
      @set 'userCountry', results[1]["address_components"][4]["long_name"]

  init: ->
    this._super()

    # Begin geo location inquiry
    @get('geolocation').start()

    # You can use event handlers
    @get('geolocation').on 'change', (geoposition) =>
      @setLocation geoposition

    @get('geolocation').on 'error', ->
      console.log("SOME ERR");

    # Or you can simply do like that
    this.get('geolocation').getGeoposition().then (geoposition) =>
      @setLocation geoposition

  placesSearchComplete: ->
    $.ajax
      url: @get('handlerApi')
      data: {searchId: @get('search').id}
      method: "post"
      success: (result) =>
        @set 'searching', false
        @transitionTo 'search', @get('search').id
      fail: (result) ->
        alert "shit, something went wrong"

  formatNumber: (number) ->
    return false if number == undefined
    match = number.match(/\(\d{3}\) \d{3}-\d{4}/)
    if match
      match[0]
    else
      false


  createAllPlaces: (places, currentIndex) ->
    nextIndex = currentIndex + 5
    currentBatch = places.slice(currentIndex, nextIndex)
    for place in currentBatch
      @getPlacesService(this).getDetails {placeId: place.place_id}, (place, status) =>
        formatted_phone_number = @formatNumber place.formatted_phone_number
        if formatted_phone_number
          @store.createRecord("place", {
            search: @get('search')
            name: place.name
            status: "created"
            response: null
            phone: formatted_phone_number
            # phone: "(707) 849-6085"
            address: place.formatted_address
          }).save().then (newPlace) =>
            @get('search').get('places').then (places) =>
              places.pushObject newPlace
              @get('search').save()
              @set 'placesCount', @get('placesCount') - 1
              @placesSearchComplete() if @get('placesCount') == 0
        else
          @set 'placesCount', @get('placesCount') - 1
          @placesSearchComplete() if @get('placesCount') == 0
    setTimeout =>
      @createAllPlaces(places, nextIndex) if places[nextIndex] != undefined
    , 2000

  checkDensity: (results) ->
    if @get('currentRadius') > 4828 && @get('placesCount') < 5
      alert("We cannot find enough liquor stores in your area. Move somewhere else.")
    else if @get('placesCount') < 12
    # else if @get('placesCount') < 2
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
      @set 'searching', true
      newSearch = @store.createRecord 'search', {
        boozType: @get('boozType')
        latitude: @get('latitude')
        longitude: @get('longitude')
      }

      newSearch.save().then (search) =>
        @set 'search', search
        @nearbySearch()

`export default MainController`
