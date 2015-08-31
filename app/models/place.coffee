`import DS from 'ember-data'`

Place = DS.Model.extend {
  name: DS.attr "string"
  search: DS.belongsTo "search", async: true
  status: DS.attr "string"
  phone: DS.attr "string"
  response: DS.attr "string"
  address: DS.attr "string"
  isComplete: Ember.computed.equal('status', 'complete')
  inStock: Ember.computed.equal('response', 'in stock')
  notInStock: Ember.computed.equal('status', 'not in stock')
  noAnswer: (->
    @get('isComplete') && !@get('response')
  ).property('status', 'response')
  statusClass: (->
    if @get('isComplete')
      switch @get('response')
        when "in stock" then "success"
        when "not in stock" then "danger"
        else
          "primary"
  ).property('status', 'response')
  statusIconClass: (->
    if @get('isComplete')
      switch @get('response')
        when "in stock" then "thumbs-up"
        when "not in stock" then "thumbs-down"
        else
          "times"
  ).property('status', 'response')
}

`export default Place`
