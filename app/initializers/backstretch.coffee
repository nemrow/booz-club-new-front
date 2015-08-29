# Takes two parameters: container and application
initialize = () ->
  $.backstretch "https://s3-us-west-2.amazonaws.com/booz-club/assets/bg-img-7701247511a5526715f844fbbfe6d7ac.jpg"

BackstretchInitializer =
  name: 'backstretch'
  initialize: initialize

`export {initialize}`
`export default BackstretchInitializer`
