View = require 'views/base/view'
template = require 'views/templates/intro'
config = require 'config'
utils = require 'lib/utils'

module.exports = class IntroView extends View
  autoRender: true
  className: 'jumbotron'
  region: 'intro'
  template: template

  initialize: (options) =>
    super
    utils.log 'initializing intro view'

  render: ->
    super
    utils.log 'rendering intro view'

  getTemplateData: =>
    utils.log 'get intro view template data'
    templateData = super
    templateData.site = config.site
    templateData
