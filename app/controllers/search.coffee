`import Ember from 'ember'`

SearchController = Ember.ArrayController.extend
  percentComplete: 0

  placeCount: (->
    @get('model.length')
  ).property('model.length')

  inStockCount: (->
    count = 0
    @get('model').forEach (place) ->
      count += 1 if place.get('response') == "in stock"
    count
  ).property('model.@each.response')

  outOfStockCount: (->
    count = 0
    @get('model').forEach (place) ->
      count += 1 if place.get('response') == "not in stock"
    count
  ).property('model.@each.response')

  noResponseCount: (->
    count = 0
    @get('model').forEach (place) ->
      count += 1 if place.get('response') == undefined
    count
  ).property('model.@each.response')

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
