Spine ?= require("spine")
$      = Spine.$

class Editor extends Spine.Controller
  
  elements:
    '.editEditor'  : 'editEl'

  events:
    "keydown"    : "save"
    
  template: (item) ->
    $('#editContactTemplate').tmpl item

  constructor: ->
    super
    Spine.bind('change', @proxy @change)

  render: ->
    if @current and @current.reload?()
      @current.reload()
      @editEl.html @template @current
      @

  change: (item) ->
    @current = item
    @render()

  save: (e) ->
    return if(e.keyCode != 13)
    Spine.trigger('save', @editEl)

module?.exports = Editor