`import Ember from 'ember'`

SearchRoute = Ember.Route.extend
  model: (params) ->
    @store.find('search', params.searchId)

  setupController: (controller, model) ->
    controller.set 'model', model.get('places')
    controller.set 'search', model

`export default SearchRoute`
