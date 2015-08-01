fs = require('fs')

module.exports =
class QpitDataModelProvider
  # class static public variable
  @timerId = null

  #class prototype variable (defined by Provider API specification)
  #selector
  selector : '*'

  #disableForSelector: '.source'
  disableForSelector: null

  # default
  filterSuggestions: true
  # filterSuggestions: (suggestions, prefix) ->
  #   console.log "suggestions::" + suggestions
  #   console.log "prefix::" + prefix
  #   results = []
  #   for candidate in candidates
  #     results.push candidate
  #   results
  #
  inclusionPriority:1
  #
  excludeLowerPriority: true
  #
  suggestionPriority :1

  # class constructor-------------
  constructor: ->
    #-------
    # instance private変数 (cache)
    cachedDataModelDocuments = {}

    # getter(cachedDataModelDocuments)
    @getCachedDataModelDocuments = ->
      cachedDataModelDocuments

    # setter(cachedDataModelDocuments)
    @setCachedDataModelDocuments = (newCache) ->
      cachedDataModelDocuments = newCache

    #-------
    # instance public variable (configurations)
    @showIcon = atom.config.get('autocomplete-plus.defaultProvider') is 'Symbol'

    #string
    @apiKey = atom.config.get('qpit-autocomplete.apiKey')
    @apiKey = @apiKey?.trim()

    #string
    @apiPassword = atom.config.get('qpit-autocomplete.apiPassword')
    @apiPassword = @apiPassword?.trim()

    #string
    @apiBaseUrl = atom.config.get('qpit-autocomplete.apiBaseUrl')
    @apiBaseUrl = @apiBaseUrl?.trim()

    #string
    @dbName = atom.config.get('qpit-autocomplete.dbName')
    @dbName = @dbName?.trim()
    # concatinate apiBaseUrl and dbName for apiUrl
    @apiUrl = constructApiUrl(@apiBaseUrl, @dbName)

    # # integer NOT IMPLEMENTED
    # @autoRefleshInterval = atom.config.
    #   get('qpit-autocomplete.autoRefleshInterval')

    # string
    @autoCompleteTriggerChar = atom.config.
      get('qpit-autocomplete.autoCompleteTriggerChar')
    @autoCompleteTriggerChar = @autoCompleteTriggerChar?.trim()

    # string
    @suggestionTargetItemFieldName = atom.config.
      get('qpit-autocomplete.suggestionTargetItemFieldName')
    @suggestionTargetItemFieldName = @suggestionTargetItemFieldName?.trim()

    # boolean
    @showGrantedOnly = atom.config.
      get('qpit-autocomplete.showGrantedOnly')
    # string
    @grantedLabel = atom.config.
      get('qpit-autocomplete.grantedLabel')
    @grantedLabel = @grantedLabel?.trim()

    # array of string
    @showSpecifiedTagsOnly = validateStringArray(atom.config.
      get('qpit-autocomplete.showSpecifiedTagsOnly'))

    # boolean
    @copyToClipboardOnInserted = atom.config.
      get('qpit-autocomplete.copyToClipboardOnInserted')

    #-----------------------------------------------
    # boolean
    @enableSuggestionDataTypeName = atom.config.
      get('qpit-autocomplete.enableSuggestionDataTypeName')

    # string
    @dataTypeNamePrefix = atom.config.
      get('qpit-autocomplete.dataTypeNamePrefix')
    @dataTypeNamePrefix = @dataTypeNamePrefix?.trim()

    # string
    @dataTypeNamePostfix = atom.config.
      get('qpit-autocomplete.dataTypeNamePostfix')
    @dataTypeNamePostfix = @dataTypeNamePostfix?.trim()

    #-----------------------------------------------
    # boolean
    @enableSuggestionDataItemName = atom.config.
      get('qpit-autocomplete.enableSuggestionDataItemName')

    # string
    @dataItemNamePrefix = atom.config.
      get('qpit-autocomplete.dataItemNamePrefix')
    @dataItemNamePrefix = @dataItemNamePrefix?.trim()

    # string
    @dataItemNamePostfix = atom.config.
      get('qpit-autocomplete.dataItemNamePostfix')
    @dataItemNamePostfix = @dataItemNamePostfix?.trim()
    #-----------------------------------------------
    # boolean
    @enableSuggestionEntityName = atom.config.
      get('qpit-autocomplete.enableSuggestionEntityName')

    # string
    @entityNamePrefix = atom.config.
      get('qpit-autocomplete.entityNamePrefix')
    @entityNamePrefix = @entityNamePrefix?.trim()

    # string
    @entityNamePostfix = atom.config.
      get('qpit-autocomplete.entityNamePostfix')
    @entityNamePostfix = @entityNamePostfix?.trim()
    #-----------------------------------------------
    # boolean
    @enableSuggestionCodeName = atom.config.
      get('qpit-autocomplete.enableSuggestionCodeName')

    # string
    @codeNamePrefix = atom.config.
      get('qpit-autocomplete.codeNamePrefix')
    @codeNamePrefix = @codeNamePrefix?.trim()

    # string
    @codeNamePostfix = atom.config.
      get('qpit-autocomplete.codeNamePostfix')
    @codeNamePostfix = @codeNamePostfix?.trim()
    #-----------------------------------------------
    # boolean
    @enableSuggestionOther = atom.config.
      get('qpit-autocomplete.enableSuggestionOther')

    # string
    @otherNamePrefix = atom.config.
      get('qpit-autocomplete.otherNamePrefix')
    @otherNamePrefix = @otherNamePrefix?.trim()

    # string
    @otherNamePostfix = atom.config.
      get('qpit-autocomplete.otherNamePostfix')
    @otherNamePostfix = @otherNamePostfix?.trim()

    #------------------------------------------------
    # boolean
    @formatLocalJsonCacheFile = atom.config.
      get('qpit-autocomplete.formatLocalJsonCacheFile')


    # regist an event listeners
    atom.config.onDidChange('qpit-autocomplete.apiKey',
      (event) =>
        @apiKey = event.newValue
    )
    atom.config.onDidChange('qpit-autocomplete.apiPassword',
      (event) =>
        @apiPassword = event.newValue
    )
    atom.config.onDidChange('qpit-autocomplete.apiBaseUrl',
      (event) =>
        @apiBaseUrl = event.newValue
        @apiUrl = constructApiUrl(@apiBaseUrl, @dbName)
    )
    atom.config.onDidChange('qpit-autocomplete.dbName',
      (event) =>
        @dbName = event.newValue
        @apiUrl =constructApiUrl(@apiBaseUrl, @dbName)
    )
    # atom.config.onDidChange('qpit-autocomplete.autoRefleshInterval',
    #   (event) ->
    #     @autoRefleshInterval = event.newValue
    # )

    atom.config.onDidChange('qpit-autocomplete.autoCompleteTriggerChar',
      (event) ->
        @autoCompleteTriggerChar = event.newValue
    )

    atom.config.onDidChange('qpit-autocomplete.suggestionTargetItemFieldName',
      (event) ->
        @suggestionTargetItemFieldName = event.newValue
    )

    atom.config.onDidChange('qpit-autocomplete.showGrantedOnly',
      (event) =>
        @showGrantedOnly = event.newValue
    )
    atom.config.onDidChange('qpit-autocomplete.grantedLabel',
      (event) =>
        @grantedLabel = event.newValue
    )
    atom.config.onDidChange('qpit-autocomplete.showSpecifiedTagsOnly',
      (event) =>
        validateStringArray(event.newValue)
        @showSpecifiedTagsOnly = event.newValue
    )
    atom.config.onDidChange('qpit-autocomplete.copyToClipboardOnInserted',
      (event) =>
        @copyToClipboardOnInserted = event.newValue
    )
    #------------------------
    atom.config.onDidChange('qpit-autocomplete.enableSuggestionDataItemName',
      (event) =>
        @enableSuggestionDataItemName = event.newValue
    )
    atom.config.onDidChange('qpit-autocomplete.dataItemNamePrefix',
      (event) =>
        @dataItemNamePrefix = event.newValue
    )
    atom.config.onDidChange('qpit-autocomplete.dataItemNamePostfix',
      (event) =>
        @dataItemNamePostfix = event.newValue
    )
    #-------------------------
    atom.config.onDidChange('qpit-autocomplete.enableSuggestionDataTypeName',
      (event) =>
        @enableSuggestionDataTypeName = event.newValue
    )
    atom.config.onDidChange('qpit-autocomplete.dataTypeNamePrefix',
      (event) =>
        @dataTypeNamePrefix = event.newValue
    )
    atom.config.onDidChange('qpit-autocomplete.dataTypeNamePostfix',
      (event) =>
        @dataTypeNamePostfix = event.newValue
    )
    #-------------------------
    atom.config.onDidChange('qpit-autocomplete.enableSuggestionEntityName',
      (event) =>
        @enableSuggestionEntityName = event.newValue
    )
    atom.config.onDidChange('qpit-autocomplete.entityNamePrefix',
      (event) =>
        @entityNamePrefix = event.newValue
    )
    atom.config.onDidChange('qpit-autocomplete.entityNamePostfix',
      (event) =>
        @entityNamePostfix = event.newValue
    )
    #-------------------------
    atom.config.onDidChange('qpit-autocomplete.enableSuggestionCodeName',
      (event) =>
        @enableSuggestionCodeName = event.newValue
    )
    atom.config.onDidChange('qpit-autocomplete.codeNamePrefix',
      (event) =>
        @codeNamePrefix = event.newValue
    )
    atom.config.onDidChange('qpit-autocomplete.codeNamePostfix',
      (event) =>
        @codeNamePostfix = event.newValue
    )
    #-------------------------
    atom.config.onDidChange('qpit-autocomplete.enableSuggestionOther',
      (event) =>
        @enableSuggestionOther = event.newValue
    )
    atom.config.onDidChange('qpit-autocomplete.otherNamePrefix',
      (event) =>
        @otherNamePrefix = event.newValue
    )
    atom.config.onDidChange('qpit-autocomplete.otherNamePostfix',
      (event) =>
        @otherNamePostfix = event.newValue
    )
    #-------------------------
    atom.config.onDidChange('qpit-autocomplete.formatLocalJsonCacheFile',
      (event) =>
        @formatLocalJsonCacheFile = event.newValue
    )

    # instance method
    # read a local cache file
    readCacheFileInHomeDirectory(
      null,
      {encoding : 'utf-8'},
      (error, data) =>
        #callback
        if (error?)
          # any errors
          # when not found directories or file, returned "ENOENT"as error code
          # make information notification
          if (error.code == 'ENOENT')
            atom.notifications.addInfo "qpit-autocomplete: no local cache\
             file at " + getHomeDirectory() ,
            {dismissable: false}
          else
            # make error notification
            atom.notifications.addError "qpit-autocomplete: failed to read\
             the local cache file at " + getHomeDirectory() ,
            {detail: "Error：" + error, dismissable: true}
        else
          # normal
          try
            # console.log (data)
            @setCachedDataModelDocuments(JSON.parse(data))
            atom.notifications.addInfo "qpit-autocomplete: reload local cache \
             file at " + getHomeDirectory() ,
            {dismissable: false}
          catch parseerr
            atom.notifications.addError "qpit-autocomplete: failed to parse \
            data from the cache data:" + data ,
            {detail: "Error：" + parseerr, dismissable: true}
    )

  #--------end of constructor

  # static public method (by Provider API specification)
  getSuggestions: ({editor, bufferPosition, scopeDescriptor, prefix}) ->
    lineTextForBeforeCursor = editor.getTextInRange([[bufferPosition.row, 0],
      bufferPosition])
    charAtCursor = lineTextForBeforeCursor.
      charAt(lineTextForBeforeCursor.length-1)

    # console.log "bufferPosition[#{bufferPosition}]"
    # console.log "lineTextForBeforeCursor[#{lineTextForBeforeCursor}]"
    # console.log "prefix[#{prefix}]"
    # console.log "scopeDescriptor[#{scopeDescriptor}]"
    # console.log "charAtCursor***#{charAtCursor}***"
    # console.log "autoCompleteTriggerChar is #{@autoCompleteTriggerChar}"

    lastTriggerIndex =
      lineTextForBeforeCursor.lastIndexOf(@autoCompleteTriggerChar)
    # unless triggerChar exists at previous of cursor position,
    # do donthing and exit.
    return unless lastTriggerIndex >= 0

    # get target string for query
    target =  lineTextForBeforeCursor.substring(lastTriggerIndex +
      @autoCompleteTriggerChar.length)
    #console.log('target='+ target)

    # if target is empty, do not show any candidates.(require one char at least)
    return unless target?
    return if target is ''

    # get candidates
    candidates = @createCandidates()

    candidate = {}
    suggestions = []

    for candidate in candidates
      continue unless candidate?

      suggestion = {}

      if isStartedWith(@suggestionTargetItemFieldName,target,candidate)
        currentName = getSuggestionTargetFieldValue(
          @suggestionTargetItemFieldName,candidate)
        currentdocType = candidate.docType
        suggestion.text = @getSuggestionText(currentdocType, currentName)
        suggestion.displayText = (currentName ?= 'NOTFOUND_NAMEJA')
        suggestion.type = getSuggestionType(candidate)
        # set leftLabel property if grantedDate is set.
        suggestion.leftLabel = @grantedLabel if candidate.grantedDate?
        suggestion.description = (candidate.description ?= '')
        suggestion.replacementPrefix = target
        suggestions.push(suggestion)

    # return suggestions
    suggestions

  # static public method (by Provider API specification)
  onDidInsertSuggestion:({editor, triggerPosition, suggestion}) ->
    #console.log "onDidInsertSuggestion is called."
    #console.log triggerPosition
    #console.log suggestion

    prefix = @getSuggestionTextPrefix(suggestion.type)

    #そのカーソルがある行の先頭(column=0)から、そのカーソル位置直前までの文字列を得る
    lineTextForBeforeCursor = editor.getTextInRange([[triggerPosition.row, 0],
      triggerPosition])

    # triggerPositionで、後ろから登場している、Trigger文字列を削除する
    triggerCharStartIdx =
      lineTextForBeforeCursor.lastIndexOf(@autoCompleteTriggerChar)
    triggerCharLastIdx = triggerCharStartIdx + @autoCompleteTriggerChar.length

    txt = lineTextForBeforeCursor.substring(0,triggerCharStartIdx)
    txt = txt + prefix
    txt = txt + lineTextForBeforeCursor.slice(triggerCharLastIdx)

    #
    editor.setTextInBufferRange([[triggerPosition.row, 0],triggerPosition],txt,
    { undo : 'skip'})

    # copy the value to clipboard with the prefix
    atom.clipboard.write(prefix + suggestion.text) if @copyToClipboardOnInserted

  # private function
  # return array of document objects.
  createCandidates : () ->
    #if already created, return it. if not, create and instantiate it.
    candidates = @getCachedDataModelDocuments().rows
    #console.log "candidates=" + candidates
    # failsafe: set empty array if candidates is null or undefined
    candidates = [] unless candidates?

    resultCandidates = []
    # filter
    for wrappedObject in candidates
      #"doc" field name is specification of CouchDB Web API , by '?include_docs=true' query parameter
      candidate = wrappedObject.doc
      #not wrapped test data.
      candidate = wrappedObject unless candidate?

      if @showGrantedOnly and !(candidate.grantedDate?)
        # showGrantedOnlyがtrueである場合、そのgrantedDateが未記入のものは除外
        continue

      if !@enableSuggestionDataItemName and isDataItem(candidate)
        # DataItemのサジェスチョンが不要で、かつそれがDataItemの場合は候補にpushしない
        continue

      if !@enableSuggestionDataTypeName and isDataType(candidate)
        # DataTypeのサジェスチョンが不要で、かつそれがDataTypeの場合は候補にpushしない
        continue

      if !@enableSuggestionEntityName and isEntity(candidate)
        # Entityのサジェスチョンが不要で、かつそれがEntityの場合は候補にpushしない
        continue

      if !@enableSuggestionCodeName and isCode(candidate)
        # Code suggestion is off, and the candidate is just code.
        continue

      if !@enableSuggestionOther and isOther(candidate)
        continue

      resultCandidates.push candidate

    #console.log(resultCandidates)
    resultCandidates

  # private getSuggestionText :まず、後を指定の文字を追加して返す
  # なぜPrefixをこのメソッドで追加しないか?
  # それは、ここで追加してしまうと、autocomplete-plusの内部仕様のため、
  # エディタ上の表示文字列と先頭文字が一致しなくなるので、画面上にコンテンツアシスト画面が表示
  # されなくなってしまうから。なので、getSuggestionTextPrefixを使って事後処理の
  # onDidInsertSuggestionメソッド内部で文字列切り貼りして帳尻を合わしている
  getSuggestionText : (docType, text) ->
    ret = null
    switch docType
      when 'DataItem'
        ret = text + (@dataItemNamePostfix ?= '')
      when 'DataType'
        ret = text + (@dataTypeNamePostfix ?= '')
      when 'Entity'
        ret = text + (@entityNamePostfix ?= '')
      when 'Code'
        ret = text + (@codeNamePostfix ?= '')
      else
        ret = text
    ret

  # function
  getSuggestionTextPrefix : (suggestionType) ->
    ret = null
    switch suggestionType
      when 'I'
        ret = (@dataItemNamePrefix ?= '')
        return ret
      when 'T'
        ret = (@dataTypeNamePrefix ?= '')
        return ret
      when 'E'
        ret = (@entityNamePrefix ?= '')
        return ret
      when 'C'
        ret = (@codeNamePrefix ?= '')
        return ret
      else
        ret = (@otherNamePrefix ?= '')
        return ret

  #
  # function getSuggestionType
  #
  getSuggestionType = ({docType}) ->
    switch docType
      when 'DataItem'
        'I'
      when 'DataType'
        'T'
      when 'Entity'
        'E'
      when 'Code'
        'C'
      else
        'X'

  createTargetUrl : () ->
    targetUrl = @apiUrl + \
      '/_design/data_model_00/_view/all_data_model_docs?include_docs=true'
    # console.log "targetUrl=" + targetUrl
    targetUrl

  # dispose this provider instance.
  dispose: () ->
    # NOT IMPLEMENTED
    # clearTimeout(
    #   QpitDataModelProvider.timerId) unless QpitDataModelProvider.timerId
    return

  # instance public method
  retrieveAllDataModelDocs: (callback) ->

    withErr = false

    # Notify setting errors
    if @apiKey == null or @apiKey == ''
      atom.notifications.addError "qpit-autocomplete:the setting \
      'API Key' is empty.",
      {dismissable: true}
      withErr = true

    if @apiPassword == null or @apiPassword == ''
      atom.notifications.addError "qpit-autocomplete:the setting \
      'API Password' is empty.",
      {dismissable: true}
      withErr = true

    if @apiBaseUrl == null or @apiBaseUrl == ''
      atom.notifications.addError "qpit-autocomplete:the setting \
      'API Base URL' is empty.",
      {dismissable: true}
      withErr = true

    if @dbName == null or @dbName == ''
      atom.notifications.addError "qpit-autocomplete:the setting \
      'Document DB name' is empty.",
      {dismissable: true}
      withErr = true
    # exit this function with configuration errors
    return if withErr

    atom.notifications.addInfo(
      "qpit-autocomplete: start to retrieve data from the server..." ,
      {dismissable: false}
    )

    #console.log "QpitDataModelProvider.retrieveAllDataModelDocs was called."
    targetUrl = @createTargetUrl()

    resultData = {}
    try
      #create XMLHttpRequest instance if not exists yet.
      xhr = new XMLHttpRequest() unless xhr?
      xhr.abort if xhr.readyState > 0
      xhr.responseType = 'json'
      xhr.timeout = 30 * 1000
      #change to using Authorization header.
      #xhr.open("GET", targetUrl, true, @apiKey, @apiPassword )
      xhr.open("GET", targetUrl, true)
      xhr.setRequestHeader('Authorization', "Basic " + getBasicAuthToken(@apiKey, @apiPassword))
      xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest')
      xhr.setRequestHeader('Content-Type', 'application/json')
      xhr.onreadystatechange = () ->
        if xhr.readyState != 4 # 4 = DONE
          return
        if xhr.status != 200 # error
          atom.notifications.addError "qpit-autocomplete: failed to access \
          the server, API URL:" + targetUrl ,
          {detail: "Error：" + error, dismissable: true}
          console.log error
          return

        # receive async response
        resultData = xhr.response
        if callback? and typeof(callback) is 'function'
          callback({response : resultData})

        # write raw response to local cache (in HOME directory)
        formatString = null
        if @formatLocalJsonCacheFile
          formatString = '\t'
        else
          formatString = null

        writeCacheFileInHomeDirectory(null,
          #JSON.stringify(resultData, null, '\t'),
          JSON.stringify(resultData, null, formatString),
          {
            encoding : 'utf-8'
          },
          (error) ->
            #callback when writeFile completed
            if error?
              atom.notifications.addError "qpit-autocomplete: failed to write \
              cache file to home directory :" + getHomeDirectory(),
              {detail: "Error：" + error, dismissable: true}
        )
        atom.notifications.addSuccess(
          "qpit-autocomplete: reflesh data from the server succesfully." ,
          {dismissable: false}
        )
      xhr.send(null) # null or "" for GET request
    catch error
      console.log error
      atom.notifications.addError "qpit-autocomplete: failed to access \
      the server, API URL:" + targetUrl ,
      {detail: "Error：" + error, dismissable: true}
      return



#----- non classed global function
ascendingPrefixComparator = (a, b) -> a.prefix  - b.prefix

firstCharsEqual = (str1, str2) ->
  str1[0].toLowerCase() is str2[0].toLowerCase()

validateStringArray = (array) ->
  ret = []
  for data in array
    ret.push(data) if data? and data isnt ''

constructApiUrl = (apiBaseUrl, dbName) ->
  urlLastChar = apiBaseUrl?.trim().slice(-1)
  if urlLastChar? and urlLastChar is '/'
    apiBaseUrl = apiBaseUrl.trim().slice(0,-1)
  apiUrl = apiBaseUrl.trim() + '/' + dbName?.trim()
  apiUrl
  # console.log "QPIT apiUrl is [#{apiUrl}]"

isStartedWith = (fieldname, target, candidateDoc) ->
  field = candidateDoc[fieldname]
  return false if !field? #return false(=not matched)
  # if prefix of field is matched to the target string, return true
  return field.lastIndexOf(target, 0) == 0

getSuggestionTargetFieldValue = (fieldname, candidateDoc) ->
  return candidateDoc[fieldname]

isEntity = ({docType}) ->
  if docType? and docType == 'Entity'
    true
  else
    false

isDataItem = ({docType}) ->
  if docType? and docType == 'DataItem'
    true
  else
    false

isDataType = ({docType}) ->
  if docType? and docType == 'DataType'
    true
  else
    false

isCode = ({docType}) ->
  if docType? and docType == 'Code'
    true
  else
    false

isPrimitiveType = ({docType}) ->
  if docType? and docType == 'PrimitiveType'
    true
  else
    false

isTag = ({docType}) ->
  if docType? and docType == 'Tag'
    true
  else
    false

isOther = ({docType}) ->
  if isDataItem({docType}) or isEntity({docType}) or isDataType({docType}) or isCode({docType})
    false
  else
    true

# static func
# alternative : use the directory by atom.getConfigDirPath() api.
getHomeDirectory = ()->
  if process.platform is 'win32'
    process.env.USERPROFILE
  else
    process.env.HOME

# static function
# write the cached file asynchronously.
writeCacheFileInHomeDirectory = (filename, content, options, callback) ->
  homeDir = getHomeDirectory()
  filePath = homeDir + '/' + (filename?.trim() || '.qpit-autocomplete.cache')
  # overwrite if the file had already existed.
  fs.writeFile(filePath, content, options, callback)

# static function
# read the cached file asynchronously.
readCacheFileInHomeDirectory = (filename, options, callback) ->
  homeDir = getHomeDirectory()
  filePath = homeDir + '/' + (filename?.trim() || '.qpit-autocomplete.cache')
  # no need to check the existenceof file
  fs.readFile(filePath, options, callback)

# static function
getBasicAuthToken = (user, passwd) ->
  user_base64 = new Buffer(user + ':' + passwd).toString('base64')
  user_base64
