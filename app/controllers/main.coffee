`import Ember from 'ember'`

MainController = Ember.Controller.extend
  actions:
    beginSearch: ->
      newSearch = @store.createRecord 'search', {
        boozType: @get('boozType')
      }
      newSearch.save().then (search) =>
        @transitionTo 'search', search.id


`export default MainController`
