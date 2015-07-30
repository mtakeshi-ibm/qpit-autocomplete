{$, $$, ScrollView, View} = require 'atom-space-pen-views'

module.exports =
class LocalCacheStatusView extends ScrollView
  #self instance
  localCacheStatusView : null

  provider = null

  @content: (provider)->
    #console.log "provider.getCachedDataModelDocuments()=" + provider.getCachedDataModelDocuments().rows
    @div class: 'primary-line', =>
      @span class:'qpit-localcachestatus qpit-cached-documents', "Local Cached Data Size = "\
       + provider?.getCachedDataModelDocuments()?.rows?.length

  activate: ->
    new LocalCacheStatusView()

  initialize : (serializeState) ->
    super
    @addClass('qpit-localcachestatus')

  # Returns an object that can be retrieved when package is activated
  serialize: ->
    # do nothing.

  # entry point from main.coffee
  toggle : (localCacheStatusView, provider) ->
    @localCacheStatusView = localCacheStatusView
    LocalCacheStatusView.provider = provider

    if @panel?.isVisible()
      @hide()
    else
      @show()

  hide : ->
    #hide SelectItemView UI
    @panel?.hide()

  show : ->
    @panel ?= atom.workspace.addModalPanel(item : this)
    @panel.show()
