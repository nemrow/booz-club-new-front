`import Ember from 'ember'`

SearchController = Ember.ArrayController.extend
  percentComplete: 0

  searchInProgress: (->
    @get('percentComplete') != 100
  ).property('percentComplete')

  updatePercentComplete: (->
    if @get('model')
      placeCount = @get('model.length')
      completePlaceCount = 0
      @get('model').then (places) =>
        places.forEach (place) =>
          completePlaceCount += 1 if place.get('status') == "complete"
        @set 'percentComplete', (completePlaceCount / placeCount) * 100
  ).observes('model.@each.status')

`export default SearchController`
