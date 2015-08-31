`import Ember from 'ember'`

SearchController = Ember.Controller.extend
  percentComplete: 0
  searchInProgress: (->
    @get('percentComplete') != 100
  ).property('percentComplete')

  completedSearches: (->
    if @get('model.places')
      @get('model.places')
  ).property('model.places.@each.status')

  updatePercentComplete: (->
    if @get('model.places')
      placeCount = @get('model.places.length')
      completePlaceCount = 0
      @get('model.places').then (places) =>
        places.forEach (place) =>
          completePlaceCount += 1 if place.get('status') == "complete"
        @set 'percentComplete', (completePlaceCount / placeCount) * 100
  ).observes('model.places.@each.status')

`export default SearchController`
