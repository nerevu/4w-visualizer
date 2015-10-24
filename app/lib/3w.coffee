mediator = require 'mediator'

module.exports = class ThreeW
  constructor: (options) ->
    # required
    selection = options.selection
    @data = options.data
    @geom = options.geometry

    # optional
    numColors = options.numColors or 5
    colorScheme = options.colorScheme or 'Reds'
    @whoSelector = selection + '-who'
    @whatSelector = selection + '-what'
    @whereSelector = selection + '-where'
    @countSelector = selection + '-count'
    @sliderSelector = selection + '-slider'
    @whoField = options.whoField or 'Organization'
    @whatField = options.whatField or 'Activity'
    @whereField = options.whereField or 'Location'
    @joiner = options.joinAttribute or 'Location'
    @namer = options.nameAttribute or 'Name'
    @top = options.top or 10
    @height = options.height or 350
    @colors = colorbrewer[colorScheme][numColors]

  calcProjection: (projection, width) =>
    # http://stackoverflow.com/a/14691788/408556
    path = d3.geo.path().projection(projection)
    b = path.bounds(@geom)
    bheight = Math.abs(b[1][1]  - b[0][1])
    bwidth = Math.abs(b[1][0] - b[0][0] )
    s = .9 / Math.max(bwidth / width, bheight / @height)
    t0 = (width - s * (b[1][0] + b[0][0])) / 2
    t1 = (@height - s * (b[1][1] + b[0][1])) / 2

    result =
      scale: s
      width: (width - s * (b[1][0] + b[0][0])) / 2
      height: (@height - s * (b[1][1] + b[0][1])) / 2

    result

  drawCharts: =>
    keys = (f.properties[@joiner] for f in @geom.features)
    values = (f.properties[@namer] for f in @geom.features)
    lookup = _.object keys, values
    margins = top: 0, left: 10, right: 10, bottom: 35
    add = (p, v) -> v.size
    remove = (p, v) -> v.size
    init = -> 0

    @whoChart = dc.rowChart @whoSelector
    @whatChart = dc.rowChart @whatSelector
    @whereChart = dc.geoChoroplethChart @whereSelector
    # @countChart = dc.numberDisplay @countSelector

    cf = crossfilter(@data)

    whoDimension = cf.dimension (d) => d[@whoField]
    whatDimension = cf.dimension (d) => d[@whatField]
    whereDimension = cf.dimension (d) => d[@whereField]

    whoGroup = whoDimension.group()
    whatGroup = whatDimension.group()
    whereGroup = whereDimension.group()

    whoWidth = $(@whoSelector).width()
    whatWidth = $(@whatSelector).width()
    whereWidth = $(@whereSelector).width()

    @whoChart
      .dimension(whoDimension)
      .group(whoGroup)
      .width(whoWidth)
      .height(@height)
      .margins(margins)
      .elasticX(true)
      .data((dimension) => dimension.top(@top))
      .labelOffsetY(13)
      .colors([@colors[1]])
      .colorAccessor((d, i) -> 0)
      .xAxis()
      .ticks(5)

    @whatChart
      .dimension(whatDimension)
      .group(whatGroup)
      .width(whatWidth)
      .height(@height)
      .margins(margins)
      .elasticX(true)
      .data((dimension) => dimension.top(@top))
      .labelOffsetY(13)
      .colors([@colors[1]])
      .colorAccessor((d, i) -> 0)
      .xAxis()
      .ticks(5)

    projection = d3.geo.mercator().scale(1).translate([0, 0])
    r = @calcProjection projection, whereWidth
    @projection = projection.scale(r.scale).translate([r.width, r.height])

    @whereChart
      .dimension(whereDimension)
      .projection(@projection)
      .group(whereGroup)
      .colors(@colors)
      .colorDomain(d3.extent(_.pluck(whereGroup.all(), 'value')))
      .colorCalculator((d) => if d then @whereChart.colors()(d) else '#ccc')
      .overlayGeoJson(@geom.features, 'County', (d) =>
        d.properties[@joiner] or '')
      .title((d) ->"County: #{lookup[d.key]}\nActivities: #{d.value or 0}")

    # @countChart
    #   .group({value: -> whereGroup.size()})
    #   .valueAccessor((d) -> d)
    #   .formatNumber((d) -> d3.format("0,000")(parseInt(d)))
    #   .html(
    #     one:'%number district'
    #     some:'%number districts'
    #     none:'zero districts')

    dc.renderAll()

    g = d3.selectAll(@whoSelector).select('svg').append('g')

    g.append('text')
      .attr('class', 'x-axis-label')
      .attr('text-anchor', 'middle')
      .attr('x', whoWidth / 2)
      .attr('y', @height)
      .text('# of Activities')

    g = d3.selectAll(@whatSelector).select('svg').append('g')

    g.append('text')
      .attr('class', 'x-axis-label')
      .attr('text-anchor', 'middle')
      .attr('x', whatWidth / 2)
      .attr('y', @height)
      .text('# of Activities')

  resizeCharts: =>
    @whoChart.width $(@whoSelector).width()
    @whatChart.width $(@whatSelector).width()
    dc.redrawAll()

    r = @calcProjection @projection, $(@whereSelector).width()
    scale = r.scale
    translate = "#{r.width}, #{r.height}"

    # http://bl.ocks.org/mbostock/2206590
    d3.selectAll(@whereSelector).select('svg').transition()
      .duration(750)
      .attr("transform", "scale(#{scale})translate(#{translate})")

  updateCharts: (chart, filter) ->
    dc.filterAll()
    chart.filter [filter]
    dc.redrawAll()

  updateHandle: (e, value) =>
    m = moment new Date("5/#{value}/2015")
    e.textContent = m.format("l")
    @value = value

  initSlider: =>
    # tipstrategies.com/geography-of-jobs/
    # github.com/rgdonohue/d3-animated-world/blob/master/js/main.js
    @whos_who = _.pluck @whoChart.group().top(10), 'key'
    @paused = false
    @start = 20
    @max = 31
    @$element = $('input[type="range"]')
    $handle = $('#value')[0]
    updateHandle = @updateHandle

    @$element.rangeslider(
      polyfill: false
      onInit: -> updateHandle $handle, @value
      onSlide: (pos, value) ->
        updateHandle $handle, value

      onSlideEnd: (pos, value) =>
        @updateCharts @whoChart, _.sample(@whos_who, 2)
    )

  play: (value) =>
    if (value <= @max) and not @paused
      @$element.val(value).change()
      @updateCharts @whoChart, _.sample(@whos_who, 2)
      setTimeout (=> @play(value + 1)), 500
    else if @paused
      @paused = false
    else if value > @max
      console.log 'done'
      mediator.publish 'done'

  pause: => @paused = true
  reset: =>
    console.log 'really reset!'
    @$element.val(@start).change()
    @updateCharts @whoChart, _.sample(@whos_who, 2)
