`import Ember from 'ember'`

MainController = Ember.Controller.extend
  latitude: null
  longitude: null
  boozType: null
  placesCount: 0

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

  placesSearchComplete: (search) ->
    $.ajax
      url: "http://localhost:3000/search"
      data: {searchId: search.id}
      method: "post"
      success: (result) =>
        @transitionTo 'search', search.id
      fail: (result) ->
        alert "shit, something went wrong"

  createAllPlaces: (places, placesService, currentIndex, search) ->
    nextIndex = currentIndex + 5
    currentBatch = places.slice(currentIndex, nextIndex)
    for place in currentBatch
      placesService.getDetails {placeId: place.place_id}, (place, status) =>
        @store.createRecord("place", {
          search: search
          name: place.name
          status: "created"
          response: null
          # phone: place.formatted_phone_number
          phone: "(707) 849-6085"
          address: place.formatted_address
        }).save().then (newPlace) =>
          search.get('places').then (places) =>
            places.pushObject newPlace
            search.save()
            @set 'placesCount', @get('placesCount') - 1
            console.log @get("placesCount")
            @placesSearchComplete(search) if @get('placesCount') == 0
    setTimeout =>
      @createAllPlaces(places, placesService, nextIndex, search) if places[nextIndex] != undefined
    , 2000

  actions:
    beginSearch: ->
      latLng = new google.maps.LatLng(@get('latitude'), @get('longitude'))
      map = new google.maps.Map($('.map')[0], {center: latLng, zoom: 15})
      placesService = new google.maps.places.PlacesService(map)

      newSearch = @store.createRecord 'search', {
        boozType: @get('boozType')
        latitude: @get('latitude')
        longitude: @get('longitude')
      }

      nearbyRequestData = {
        location: latLng
        radius: 300
        open_now: true
        types: ['liquor_store']
      }

      newSearch.save().then (search) =>
        placesService.nearbySearch nearbyRequestData, (results) =>
          @set "placesCount", results.length
          @createAllPlaces(results, placesService, 0, search)






`export default MainController`
