`import Ember from 'ember'`

SearchController = Ember.Controller.extend
  completedSearches: (->
    @get('model.places')
  ).property('model.places.@each.status')

`export default SearchController`
