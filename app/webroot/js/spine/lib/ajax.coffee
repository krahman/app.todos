Spine ?= require("spine")
$      = Spine.$
Model  = Spine.Model

Ajax =
  enabled:  true
  pending:  false
  requests: []
  getURL: (object) ->
    object and object.url?() or object.url

  disable: (callback) ->
    @enabled = false
    callback()
    @enabled = true

  requestNext: ->
    next = @requests.shift()
    if next
      @request.apply(@, next)
    else
      @pending = false

  request: (params) ->
    console.log 'Ajax::request'
    console.log params if params
    success = params.success
    error = params.error
    params.error= =>
      error?(arguments...)
      @requestNext()
    params.success = =>
      success?(arguments...)
      @requestNext()
    $.ajax(params)

  send: ->
    return unless @enabled
    if @pending
      @requests.push(arguments)
    else
      @pending = true
      @request(arguments...)
    
class Base
  defaults:
    contentType: "application/json"
    dataType: "json"
    processData: false
  
  send: (params, defaults) ->
    console.log 'Base::send'
    console.log params if params
    Ajax.send($.extend({}, @defaults, defaults, params))

class Collection extends Base
  constructor: (@model) -> 
    super
    @url = Ajax.getURL(@model)
    
  findAll: (params) ->
    @send params,
          type:    "GET",
          url:     @url,
          success: @recordsResponse(params)
          error: @errorResponse(params)
    
  fetch: ->
    @findAll success: (records) =>
      @model.refresh(records)
    
  recordsResponse: (params) =>
    console.log params if params
    success = params.success
    
    (data, status, xhr) =>
      @model.trigger("ajaxSuccess", null, status, xhr)
      success?(@model.fromJSON(data))

  errorResponse: (params = {}) =>
    error = params.error

    (jqXHR, statusText, error) =>
      @model.trigger("ajaxError", null ,jqXHR, statusText, error)
      error?(@model)


class Singleton extends Base
  constructor: (@record) ->
    super
    console.log 'Singleton::constructor'
    console.log @record
    @model = @record.constructor
    @url   = Ajax.getURL(@record)
    @base  = Ajax.getURL(@model)
  
  find: (params) ->
    @send params,
          type: "GET"
          url:  @url
  
  create: (params) ->
    console.log 'Singleton:create'
    console.log params if params
    @send params,
          type:    "POST"
          data:    JSON.stringify(@records)
          url:     @base
          success: @recordResponse(params)
          error: @errorResponse(params)


  update: (params) ->
    @send params,
          type:    "PUT"
          data:    JSON.stringify(@records)
          url:     @url
          success: @recordResponse(params)
          error: @errorResponse(params)

  
  destroy: (params) ->
    console.log 'Singleton:destroy'
    console.log params if params
    @send params,
          type:    "DELETE"
          url:     @url
          success: @blankResponse(params)
          error: @errorResponse(params)
  
  # Private

  recordResponse: (params = {}) =>
    console.log params  if params
    success = params.success
  
    (data, status, xhr) =>
      @record.trigger("ajaxSuccess", @record, status, xhr)

      return if not data or params.data is data
      data = @model.fromJSON(data)

      Ajax.disable =>
        # ID change, need to do some shifting
        if data.id and @record.id isnt data.id
          @record.changeID(data.id)

        # Update with latest data
        @record.updateAttributes(data.attributes())
      
      success?(@record)
      
  blankResponse: (params = {}) =>
    success = params.success
  
    (data, status, xhr) =>
      @record.trigger("ajaxSuccess", @record, status, xhr)

      success?(@record)

  errorResponse: (params = {}) =>
    error = params.error

    (jqXHR, statusText, error) =>
      @record.trigger("ajaxError", @record, jqXHR, statusText, error)

      error?(@record)

# Ajax endpoint
Model.host = ""

Include =
  ajax: -> new Singleton @

  url: ->
    base = Ajax.getURL(@constructor)
    base += "/" unless base.charAt(base.length - 1) is "/"
    base += encodeURIComponent(@id)
    base

Model.Ajax =
  ajax: -> new Collection @

  extended: ->
    @change (record, type) ->
      record.ajax()[type](params)
      
    @fetch ->
      @ajax().fetch(arguments...)
      
    @include Include

  url: ->
    "#{Model.host}/#{@className.toLowerCase()}s"
    
# Globals
Spine.Ajax      = Ajax
module?.exports = Ajax