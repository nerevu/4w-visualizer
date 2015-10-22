Model = require 'models/base/model'
utils = require 'lib/utils'
geometry = require 'data/geometry'

module.exports = class Geometry extends Model
  fetch: =>
    utils.log "fetch Geometry model"
    @set geometry: geometry
