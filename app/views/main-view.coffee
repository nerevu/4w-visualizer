View = require 'views/base/view'
template = require 'views/templates/home'
config = require 'config'
utils = require 'lib/utils'
mediator = require 'mediator'
ThreeW = require 'lib/3w'

module.exports = class MainView extends View
  autoRender: true
  id: 'three-w-visualization-wrapper'
  className: 'row'
  region: 'content'
  template: template

  initialize: (options) =>
    super
    utils.log 'initializing main view'
    @options = _.extend(options, config)
    @options.selection = '#three-w'
    @size = @getViewSize()
    @threew = new ThreeW @options
    _.debounce $(window).on('resize', @resize), 75

  render: =>
    super
    _.defer =>
      @threew.drawCharts()
      @threew.initSlider()

  getViewSize: =>
    for size in ['lg', 'md', 'sm', 'xs']
      if $(".device-#{size}").is(':visible')
        return size

  resize: =>
    size = @getViewSize()

    if (size isnt @size) or (size is 'lg') or (size is 'xs')
      @size = size
      _.defer @threew.resizeCharts

  getTemplateData: =>
    utils.log 'get main view template data'
    templateData = super
    templateData.top = @threew.top
    templateData
