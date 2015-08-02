# load a provider class for autocomplete-plus package
QpitDataModelProvider = require './provider'
# load atom core package
{CompositeDisposable, $} = require 'atom'

module.exports = QpitAutocomplete =
  #SelectListView
  qpitAutocompleteView: null

  #View
  localCacheStatusView: null

  subscriptions: null

  # whether is this module activated?
  activated: false

  # Atom package specification API, configurations
  config:
    apiKey:
      title : 'API key for document DB (required and case sensitive)'
      description : 'input API key which is informed by Administrator.'
      type:'string'
      default : ''
      order: 10
    apiPassword:
      title : 'API password for document DB (required and case sensitive)'
      description :'input API password which is informed by your administrator.'
      type:'string'
      default : ''
      order: 20
    apiBaseUrl:
      title : 'API Base URL for document DB (required and case sensitive)'
      description : 'API URL for the server. DO NOT include the DB name as a
      part of URL. example-> https://YOUR_ACCOUNT.cloudant.com/'
      type:'string'
      default : ''
      order: 30
    dbName:
      title : 'Name of document DB (required and case sensitive)'
      description : 'for a part of the API URL. ex-> qpitdb(default)'
      type:'string'
      default : 'qpitdb'
      order: 40
    maxItemSize:
      title : 'Maximum number of candidates'
      description : 'maximum limit to show.'
      type:'integer'
      default : 50
      enum : [10, 50, 150, 200, 250, 300]
      order: 50
    # autoRefleshInterval:
    #   title : 'Interval time (minutes) for auto-refleshing new data'
    #   description : 'Zero means that auto-reflesh is disabled.(default)'
    #   type:'integer'
    #   default: 0
    #   enum : [0, 1, 3, 5, 10, 15, 20, 30, 40, 50, 60]
    #   order: 55
    autoCompleteTriggerChar:
      title : 'Auto completion trigger character(s) in text editor'
      description : 'trigger characters for auto completion.'
      type:'string'
      default: '@'
      enum : ['*', '**', '@', '@@' ]
      order: 60
    suggestionTargetItemFieldName:
      title : 'Field name of a suggested target Item'
      description : ''
      type:'string'
      default: 'nameJa'
      enum : ['name', 'nameJa']
      order: 65
    showGrantedOnly:
      title : 'Show granted items only'
      description : 'limit to granted items.'
      type : 'boolean'
      default : false
      order : 70
    grantedLabel:
      title : 'Label for granted Items'
      description : 'display label for granted.'
      type : 'string'
      default : 'Granted'
      order : 80
    showSpecifiedTagsOnly:
      title : 'Show specified tags only'
      description : 'input tag names (comma separated)'
      type : 'array'
      default : []
      items:
        type: 'string'
      order : 90
    copyToClipboardOnInserted:
      title : 'Copy to clipboard on selection'
      description : 'copy the suggested text to clipboard when you choose it.'
      type : 'boolean'
      default : true
      order : 100
    #--------------------------
    enableSuggestionDataItemName:
      title : 'Enable suggestion for name of DataItem'
      description : ''
      type:'boolean'
      default: true
      order : 110
    dataItemNamePrefix:
      title: 'Prefix of DataItem Suggestion'
      description : 'prefix string for suggestion text.'
      type:'string'
      default:''
      order :120
    dataItemNamePostfix:
      title: 'Postfix of DataItem Suggestion'
      description : 'postfix string for suggestion text.'
      type:'string'
      default:''
      order:130
    #--------------------------
    enableSuggestionDataTypeName:
      title : 'Enable suggestion for name of DataType'
      description : ''
      type:'boolean'
      default: true
      order : 140
    dataTypeNamePrefix:
      title: 'Prefix of DataType Suggestion'
      description : 'prefix string for suggestion text.'
      type:'string'
      default:''
      order :150
    dataTypeNamePostfix:
      title: 'Postfix of DataType Suggestion'
      description : 'postfix string for suggestion text.'
      type:'string'
      default:''
      order:160
    #--------------------------
    enableSuggestionEntityName:
      title : 'Enable suggestion for name of Entity'
      description : ''
      type:'boolean'
      default: true
      order : 170
    entityNamePrefix:
      title: 'Prefix of Entity Suggestion'
      description : 'prefix string for suggestion text.'
      type:'string'
      default:''
      order :180
    entityNamePostfix:
      title: 'Postfix of Entity Suggestion'
      description : 'postfix string for suggestion text.'
      type:'string'
      default:''
      order:190
    #--------------------------
    enableSuggestionCodeName:
      title : 'Enable suggestion for name of Code'
      description : ''
      type:'boolean'
      default: true
      order : 200
    codeNamePrefix:
      title: 'Prefix of Code Suggestion'
      description : 'prefix string for suggestion text.'
      type:'string'
      default:''
      order :210
    codeNamePostfix:
      title: 'Postfix of Code Suggestion'
      description : 'postfix string for suggestion text.'
      type:'string'
      default:''
      order:220
    #--------------------------
    enableSuggestionOther:
      title : 'Enable suggestion for other type (ex -> PrimitiveType, etc.)'
      description : ''
      type:'boolean'
      default: true
      order : 230
    otherNamePrefix:
      title: 'Prefix of the other Suggestion'
      description : 'prefix string for suggestion text.'
      type:'string'
      default:''
      order :240
    otherNamePostfix:
      title: 'Postfix of the other Suggestion'
      description : 'postfix string for suggestion text.'
      type:'string'
      default:''
      order:250
    formatLocalJsonCacheFile:
      title: 'Format the local JSON cache file'
      description : 'padding tab characters into local json cache.'
      type:'boolean'
      default:false
      order:300

  # entiry point as a specification for Provider API
  provide: ->
    #if the provider instance already had existed , return it
    unless @provider?
      @provider = new QpitDataModelProvider()
    @provider

  activate: (state) ->
    @activated = true

    unless @provider?
      @provider = new QpitDataModelProvider()

    # Events subscribed to in atom's system can be easily cleaned up
    # with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register commands
    @subscriptions.add (
      atom.commands.add('atom-workspace',
        {
        'qpit-autocomplete:show-local-cache-status': => @showLocalCacheStatus(state)
        }
      )
    )
    @subscriptions.add (
      atom.commands.add('atom-workspace',
        {
        'qpit-autocomplete:retrieve-all-data-model-docs': => \
          @retrieveAllDataModelDocs()
        }
      )
    )
    @subscriptions.add (
      atom.commands.add('atom-workspace',
        {
        'qpit-autocomplete:toggle': => @toggle(state)
        }
      )
    )

  # Atom package specification API
  deactivate: ->
    @subscriptions.dispose()
    @qpitAutocompleteView?.destroy()
    @localCacheStatusView?.destroy()
    ##
    @provider = null

  # command method
  toggle: (state)->
    @createQpitAutocompleteView(state).toggle(@,@provider)

  # command method
  showLocalCacheStatus: (state) ->
    @createLocalCacheStatusView(state).toggle(@,@provider)

  # command method
  retrieveAllDataModelDocs: ->
    #wait for called from internal callback.
    providerInstance = @provider

    @provider.retrieveAllDataModelDocs( ({response}) ->
      #update or set a cache data of Provider instance.
      providerInstance.setCachedDataModelDocuments(response)
    )

  # method
  createQpitAutocompleteView : (state) ->
    @provide()
    unless @qpitAutocompleteView?
      QpitAutocompleteView = require './qpit-autocomplete-view'
      @qpitAutocompleteView = new QpitAutocompleteView(@provider)

    maxItemSize = atom.config.get('qpit-autocomplete.maxItemSize')
    @qpitAutocompleteView.setMaxItems(maxItemSize)
    @qpitAutocompleteView

  #method
  createLocalCacheStatusView : (state) ->
    @provide()
    unless @localCacheStatusView?
      LocalCacheStatusView = require './local-cache-status-view'
      @localCacheStatusView = new LocalCacheStatusView(@provider)

    @localCacheStatusView
