`import Ember from 'ember'`

SearchRoute = Ember.Route.extend
  model: (params) ->
    @store.find('search', params.searchId)

`export default SearchRoute`
