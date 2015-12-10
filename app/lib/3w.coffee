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
    @whenSelector = selection + '-slider-axis'
    @countSelector = selection + '-count'
    @sliderSelector = '#js-rangeslider-0'
    @whoField = options.whoField or 'Organization'
    @whatField = options.whatField or 'Activity'
    @whereField = options.whereField or 'Location'
    @startField = options.startField or 'Start Date'
    @endField = options.endField or 'End Date'
    @joiner = options.joinAttribute or 'Location'
    @namer = options.nameAttribute or 'Name'
    @format = options.dateFormat or 'l'
    @top = options.top or 10
    @height = options.height or 350
    @colors = colorbrewer[colorScheme][numColors]
    @whenStepSize = 14
    @whenTimeout = 1000

  calcProjection: (projection, width) =>
    # http://stackoverflow.com/a/14691788/408556
    path = d3.geo.path().projection projection
    b = path.bounds @geom
    bwidth = Math.abs(b[1][0] - b[0][0])
    bheight = Math.abs(b[1][1] - b[0][1])
    s = .9 / Math.max(bwidth / width, bheight / @height)

    result =
      scale: s
      width: (width - s * (b[1][0] + b[0][0])) / 2
      height: (@height - s * (b[1][1] + b[0][1])) / 2

    result

  drawCharts: =>
    keys = ((f.properties[@joiner] or '').toLowerCase() for f in @geom.features)
    values = (f.properties[@namer] for f in @geom.features)
    lookup = _.object keys, values
    margin = top: 0, bottom: 35, left: 10, right: 10
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
    whereDimension = cf.dimension (d) => d[@whereField].toLowerCase()
    @startDimension = cf.dimension (d) => new Date d[@startField]
    @endDimension = cf.dimension (d) => new Date d[@endField]
    @firstDate = new Date @startDimension.bottom(1)[0][@startField]
    @lastDate = new Date @endDimension.top(1)[0][@endField]
    @dateExtent = [@firstDate, @lastDate]

    whoGroup = whoDimension.group()
    whatGroup = whatDimension.group()
    whereGroup = whereDimension.group()
    @whenGroup = @startDimension.group()

    whoWidth = $(@whoSelector).width()
    whatWidth = $(@whatSelector).width()
    whereWidth = $(@whereSelector).width()

    @whoChart
      .dimension(whoDimension)
      .group(whoGroup)
      .width(whoWidth)
      .height(@height)
      .margins(margin)
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
      .margins(margin)
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

    # TODO: fix filter display https://dc-js.github.io/dc.js/vc/index.html
    @whereChart
      .dimension(whereDimension)
      .projection(@projection)
      .group(whereGroup)
      .colors(@colors)
      .colorDomain(d3.extent(_.pluck(whereGroup.all(), 'value')))
      .colorCalculator((d) => if d then @whereChart.colors()(d) else '#ccc')
      .overlayGeoJson(@geom.features, 'County', (d) =>
        (d.properties[@joiner] or '').toLowerCase())
      .title((d) -> "County: #{lookup[d.key]}\nActivities: #{d.value or 0}")

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

  drawAxis: =>
    # http://bl.ocks.org/mbostock/4149176
    dateFormat = d3.time.format.multi([
      ["%b", (d) -> d.getMonth()]
      ["%Y", -> true]
    ])

    whenWidth = $(@sliderSelector).width()
    whenHeight = 50
    margin = top: 0, bottom: whenHeight * 1.3, left: 15, right: 15
    axisWidth = whenWidth - margin.left - margin.right
    @axisHeight = whenHeight - margin.top - margin.bottom

    @xScale = d3.time.scale()
      .domain(@dateExtent)
      .range([0, axisWidth])

    @xAxis = d3.svg.axis()
      .scale(@xScale)
      .outerTickSize(0)
      .ticks(Math.max(whenWidth / 100, 2))
      .tickFormat(dateFormat)
      # .orient("bottom")

    @whenAxis = d3.select(@whenSelector)
      .attr('width', whenWidth)
      .attr('height', whenHeight)
      .append('g')
      .attr('transform', "translate(#{margin.left}, #{margin.right})")

    @whenAxis.append('g')
      .attr('class', 'x axis')
      .attr('transform', "translate(0, #{@axisHeight})")
      .call(@xAxis)

  resizeCharts: =>
    @whoChart.width $(@whoSelector).width()
    @whatChart.width $(@whatSelector).width()
    dc.redrawAll()

    width = @$slider.width()
    pos = width * @percent - 20
    @$fill[0].setAttribute('style', "width: #{pos}px")
    @$handle[0].setAttribute('style', "left: #{pos - 20}px")
    @xAxis.ticks(Math.max(width / 100, 2))
    @xScale.range([0, width])
    @whenAxis.select('.x.axis')
      .attr('transform', "translate(0, #{@axisHeight})")
      .call(@xAxis)

    r = @calcProjection @projection, $(@whereSelector).width()
    scale = r.scale
    translate = "#{r.width}, #{r.height}"

    # http://bl.ocks.org/mbostock/2206590
    d3.selectAll(@whereSelector).select('svg').transition()
      .duration(750)
      .attr("transform", "scale(#{scale})translate(#{translate})")

  updateCharts: (value) =>
    dc.filterAll()
    m = moment(@baseDate).add('days', value)
    @endDimension.filterRange([m.toDate(), Infinity])
    @startDimension.filterRange([@baseDate, (m.add('d', 1)).toDate()])
    dc.redrawAll()

  updateValue: (e, value) =>
    m = moment(@baseDate).add('days', value)
    e.textContent = m.format @format
    @value = value

  updatePercent: =>
    @$slider = $('#three-w-slider')
    @$fill = $('.rangeslider__fill')
    @$handle = $('.rangeslider__handle')

    width = @$slider.width()
    pos = parseInt(@$fill[0].style.width[..-3])
    @percent = (pos + 20) / width

  initSlider: =>
    # tipstrategies.com/geography-of-jobs/
    # github.com/rgdonohue/d3-animated-world/blob/master/js/main.js
    @paused = false
    @baseDate = new Date '1/1/1970'
    @min = moment(@firstDate).diff(@baseDate, 'days')
    @max = moment(@lastDate).diff(@baseDate, 'days')
    @$element = $('.slider')

    now = moment new Date()
    start = now.diff(@baseDate, 'days')
    count = $('.slider').length
    $value = $('#value')[0]

    updateValue = @updateValue
    updateCharts = @updateCharts
    drawAxis = @drawAxis
    updatePercent = @updatePercent

    @$element[0].setAttribute('min', @min)
    @$element[0].setAttribute('max', @max)
    @$element[0].setAttribute('value', start)

    @$element.rangeslider(
      polyfill: false
      onInit: ->
        updateValue $value, @value
        updateCharts @value
        updatePercent()
        drawAxis()
      onSlide: (pos, value) ->
        if @grabPos
          updateValue $value, value
      onSlideEnd: (pos, value) =>
        @updateCharts value
        @updatePercent()
    )

  play: (value) =>
    if (value <= @max) and not @paused
      @$element.val(value).change()
      @updateCharts value
      setTimeout (=> @play(value + @whenStepSize)), @whenTimeout
    else if @paused
      @paused = false
    else if value > @max
      mediator.publish 'done'

  pause: => @paused = true

  reset: =>
    @$element.val(@min).change()
    @updateCharts @min
