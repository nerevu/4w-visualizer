View = require 'views/base/view'
template = require 'views/templates/navbar'
mediator = require 'mediator'
config = require 'config'
utils = require 'lib/utils'

module.exports = class NavbarView extends View
  autoRender: true
  className: 'container'
  region: 'navbar'
  template: template

  initialize: (options) ->
    super
    utils.log 'initializing navbar view'
    @delegate 'click', '#xs-nav-reset', @clearFilters

  render: ->
    super
    utils.log 'rendering navbar view'

  clearFilters: ->
    dc.filterAll()
    dc.redrawAll()

  getTemplateData: =>
    utils.log 'get navbar view template data'
    templateData = super
    templateData.site = config.site
    templateData
