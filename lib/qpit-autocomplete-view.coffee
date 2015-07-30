{$, $$, SelectListView, View} = require 'atom-space-pen-views'

module.exports =
class QpitAutocompleteView extends SelectListView
  #self instance
  qpitAutocompleteView : null
  grantedLabel = null

  activate: ->
    #console.log "QpitAutocompleteView is activated."
    new QpitAutocompleteView()

  initialize : (serializeState) ->
    super
    @addClass('qpit-autocomplete')

  # Returns an object that can be retrieved when package is activated
  serialize: ->
    # do nothing.

  #Get the property name to use when filtering items.
  getFilterKey : ->
    filterKey = @provider.suggestionTargetItemFieldName
    filterKey

  #Get the filter query to use when fuzzy filtering the visible elements.
  getFilterQuery : ->
    inputText = @filterEditorView.getText()
    return inputText

  #
  cancelled : ->
    @hide()

  #on selected item by user
  confirmed : (item) ->
    selectedValue = @getSuggestionTargetItemFieldValue(item)

    # get current active TextEditor instance.
    editor = atom.workspace.getActiveTextEditor()
    paddedValue = @padPostPrefix(item,selectedValue)
    editor?.insertText(paddedValue)

    # copy selectedValue to clipboard
    atom.clipboard.write(paddedValue) if @provider.copyToClipboardOnInserted

    @cancel()

  #Get the message to display when there are no items.
  getEmptyMessage: (itemCount, filteredItemCount) =>
    if not itemCount
      'No data-model items retrieved yet'
    else
      super

  # entry point from main.coffee
  toggle : (qpitAutocompleteView, provider) ->
    @qpitAutocompleteView = qpitAutocompleteView
    @provider = provider

    if @panel?.isVisible()
      @hide()
    else
      @show()

  hide : ->
    #hide SelectItemView UI
    @panel?.hide()
    #recover the latest pane re-activated (important!)
    @oldActivePane?.activate()

  show : ->
    QpitAutocompleteView.grantedLabel = @provider.grantedLabel

    candidates = []
    @oldActivePane = atom.workspace.getActivePane()

    @panel ?= atom.workspace.addModalPanel(item : this)
    @panel.show()

    candidates = @provider.createCandidates()

    #sort data by suggestionTargetItemFieldName
    sortKey = @provider.suggestionTargetItemFieldName
    candidates = @sortBy(candidates, sortKey)

    @setItems(candidates)
    #Focus the fuzzy filter editor view.
    @focusFilterEditor()

  #Create a view for the given model item.
  viewForItem: (candidate) ->
    candidateValue = @getSuggestionTargetItemFieldValue(candidate)
    candidateSymbol = @getSuggestionTargetSymbol(candidate)

    $$ ->
      @li class:'two-lines','data-candidate-targetvalue':candidateValue, =>
        # item for first row
        @div class: 'primary-line', =>
          @span class:'qpit-autocomplete qpit-candidate-list-symbol', candidateSymbol
          @span '\t'
          @span class:'qpit-autocomplete qpit-candidate-list-value', candidateValue
          if candidate.grantedDate?
            @span '\t'
            @span class:'qpit-autocomplete qpit-candidate-list-label-granted', '('+ QpitAutocompleteView.grantedLabel + ')'
        # item for second row
        if candidate.description
          @div class: 'secondary-line', =>
            @div class: 'qpit-autocomplete qpit-candidate-list-description', candidate.description

  # sort
  sortBy : (arr, key) ->
    arr.sort (a,b) ->
      a = (a[key] || '\uffff').toUpperCase()
      b = (b[key] || '\uffff').toUpperCase()
      return if a > b then 1 else -1

  # getvalue
  getSuggestionTargetItemFieldValue : (candidate) ->
    suggestionTargetItemFieldName = @provider.suggestionTargetItemFieldName
    candidateValue = candidate[suggestionTargetItemFieldName]
    candidateValue

  #
  getSuggestionTargetSymbol : (item) ->
    docType = item.docType
    ret = null
    switch docType
      when 'DataItem'
        ret = '[I]'
      when 'DataType'
        ret = '[T]'
      when 'Entity'
        ret = '[E]'
      when 'Code'
        ret = '[C]'
      else
        ret = '[X]'
    #return value
    ret

  # pad text between prefix and postfix
  padPostPrefix : (item, selectedValue) ->
    docType = item.docType
    ret = null
    switch docType
      when 'DataItem'
        ret = (@provider.dataItemNamePrefix) + selectedValue
        ret = ret + (@provider.dataItemNamePostfix)
      when 'DataType'
        ret = (@provider.dataTypeNamePrefix) + selectedValue
        ret = ret + (@provider.dataTypeNamePostfix)
      when 'Entity'
        ret = (@provider.entityNamePrefix) + selectedValue
        ret = ret + (@provider.entityNamePostfix)
      when 'Code'
        ret = (@provider.codeNamePrefix) + selectedValue
        ret = ret + (@provider.codeNamePostfix)
      else
        ret = (@provider.otherNamePrefix) + selectedValue
        ret = ret + (@provider.otherNamePostfix)
    #return value
    ret
