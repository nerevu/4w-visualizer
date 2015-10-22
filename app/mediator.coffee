mediator = module.exports = Chaplin.mediator

mediator.setUrl = (url) ->
  console.log "mediator.url is #{url}"
  mediator.url = url

mediator.setSynced = (response) ->
  console.log "data synced!!"
  mediator.synced = true
  mediator.publish "synced", response
