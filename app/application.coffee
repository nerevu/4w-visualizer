mediator = require 'mediator'
Collection = require 'models/data'
Geometry = require 'models/geometry'
config = require 'config'
utils = require 'lib/utils'

# The application object.
module.exports = class Application extends Chaplin.Application
  title: config.site.title

  start: ->
    # You can fetch some data here and start app by calling `super` after that.
    mediator.collection.fetch()
    mediator.geometry.fetch()
    super

  # Create additional mediator properties.
  initMediator: ->
    # Add additional application-specific properties and methods
    utils.log 'initializing mediator'
    mediator.collection = new Collection()
    mediator.geometry = new Geometry()
    mediator.synced = false
    mediator.active = {}
    mediator.url = null
    mediator.seal()
    super
