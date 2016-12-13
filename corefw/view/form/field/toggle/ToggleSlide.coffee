Ext.define "Corefw.view.form.field.toggle.ToggleSlide",
  extend: "Ext.Component"
  #alias: "widget.toggleslide"
  requires: [
    "Ext.fx.Anim"
  ]
  #@cfg {Number} duration The duration for the slide animation (defaults to
  #120)
  
  duration: 120
  
  
  #@cfg {String} onText The text to display when the toggle is in the 'On'
  #position (defaults to 'ON')
  onText: "ON"
  
  #@cfg {String} offText The text to display when the toggle is in the 'Off'
  #position (defaults to 'OFF')
  offText: "OFF"
  
  #@cfg {Boolean} resizeHandle Specifies whether the drag handle should be
  #resized to cover the on or off side (defaults to true)
  
  resizeHandle: true
  
  #@cfg {Boolean} resizeContainer Specifies whether the contain element
  #should be resized (defaults to true)
  resizeContainer: true
  
  #@cfg {String} onLabelCls The CSS class for the on label (defaults to
  #'x-toggle-slide-label-on')
  onLabelCls: "x-toggle-slide-label-on"
  
  #@cfg {String} ofLabelCls The CSS class for the off label (defaults to
  #'x-toggle-slide-label-off')
  
  offLabelCls: "x-toggle-slide-label-off"
  
  #@cfg {String} handleCls The CSS class for the drag handle (defaults to
  #'x-toggle-slide-handle')
  handleCls: "x-toggle-slide-thumb"
  disabledCls: "x-toggle-slide-disabled"
  
  #@cfg {Boolean} state The initial state of the Toggle (defaults to false)
  state: false
  
  #@cfg {Boolean} booleanMode Determines whether the internal value is
  #represented as a Boolean. If not in booleanMode the internal value
  #will be represented as the on or off label text. The value passed to
  #event listeners will also be determined on this setting (defaults to
  #true)
  
  booleanMode: true
  
  # private
  dragging: false
  diff: 0
  diff2: 0
  diff3: 0
  frame: false
  renderTpl: [
    "<div class=\"holder\">"
    "<label class=\"{onLabelCls}\">"
    "<span>{onText}</span>"
    "</label>"
    "<label class=\"{offLabelCls}\">"
    "<span>{offText}</span>"
    "</label>"
    "</div>"
  ]
  autoEl:
    tag: "div"
    cls: "x-toggle-slide-container"

  initComponent: ->
    me = this
    me.callParent arguments
    
    #@event beforechange Fires before this toggle is changed.
    #@param {Ext.form.Checkbox} this This toggle
    #@param {Boolean|String} state The next toggle state value if boolean
    #mode else the label for the next state
    
    #@event change Fires when the toggle is on or off.
    #@param {Ext.form.Checkbox} this This toggle
    #@param {Boolean|String} state the new toggle state value, boolean if
    #in boolean mode else the label
    
    me.addEvents "beforechange", "change"
    return

  beforeRender: ->
    me = this
    me.callParent()
    Ext.applyIf me.renderData,
      offLabelCls: me.offLabelCls
      offText: me.offText
      onLabelCls: me.onLabelCls
      onText: me.onText
      handleCls: me.handleCls

    return

  #Set up the hidden field
  #@param {Object} ct The container to render to.
  #@param {Object} position The position in the container to render to.
  #@private
  onRender: ->
    me = this
    me.diff = 0  unless me.resizeContainer
    unless me.resizeHandle
      me.diff2 = 3
      me.diff3 = 5
    me.callParent arguments
    me.el.addCls me.cls  if me.cls
    me.thumb = new Corefw.view.form.field.toggle.Thumb(
      ownerCt: me
      slider: me
      disabled: !!me.disabled
    )
    holder = me.el.first()
    me.onLabel = holder.first()
    me.onSpan = me.onLabel.first()
    me.offLabel = me.onLabel.next()
    me.offSpan = me.offLabel.first()
    me.thumb.render()  if me.rendered
    me.handle = me.thumb.el
    if me.resizeHandle
      me.thumb.bringToFront()
    else
      me.thumb.sendToBack()
    me.resize()
    me.disableTextSelection()
    unless me.disabled
      me.registerToggleListeners()
    else
      Corefw.view.form.field.toggle.ToggleSlide.superclass.disable.call me
    return

  #Resize assets.
  #@private
  resize: ->
    su = Corefw.util.Startup
    me = this
    container = me.el
    offlabel = me.offLabel
    onlabel = me.onLabel
    handle = me.handle
    if su.getThemeVersion() isnt 2
      if me.resizeHandle
        min = (if (onlabel.getWidth() < offlabel.getWidth()) then onlabel.getWidth() else offlabel.getWidth())
        handle.setWidth min
      if me.resizeContainer
        max = (if (onlabel.getWidth() > offlabel.getWidth()) then onlabel.getWidth() else offlabel.getWidth())
        expandPx = Math.ceil(container.getHeight() / 3)
        container.setWidth max + handle.getWidth() + expandPx
      b = handle.getWidth() / 2
      onlabel.setWidth container.getWidth() - b + me.diff2
      offlabel.setWidth container.getWidth() - b + me.diff2
      rightside = me.rightside = container.getWidth() - handle.getWidth() - me.diff
      if me.state
        handle.setLeft rightside
      else
        handle.setLeft 0
    else
      onlabel.setWidth(container.getWidth()/2)
      offlabel.setWidth(container.getWidth() /2)
    me.onDrag()
    return

  
  #Turn off text selection.
  #@private
  
  disableTextSelection: ->
    els = [
      this.el
      this.onLabel
      this.offLabel
      this.handle
    ]
    Ext.each els, (el) ->
      el.on "mousedown", (evt) ->
        evt.preventDefault()
        false

      if Ext.isIE
        el.on "startselect", (evt) ->
          evt.stopEvent()
          false

      return

    return

  #Animates the handle to the next state.
  #@private
  moveHandle: (on_, callback) ->
    me = this
    runner = new Ext.util.TaskRunner()
    to = (if on_ then me.rightside else 0)
    if me.handle
      Ext.create "Ext.fx.Anim",
        target: me.handle
        dynamic: true
        easing: "easeOut"
        duration: me.duration
        to:
          left: to

        listeners:
          beforeanimate:
            fn: (ani) ->
              me.task = runner.newTask(
                run: ->
                  me.onDrag()
                  return

                interval: 10
              )
              me.task.start()
              return

            scope: this

          afteranimate:
            fn: (ani) ->
              me.onDrag()
              me.task.destroy()
              return

            scope: this

        callback: callback

    return

  #Constrain the drag handle to the containing el.
  #@private
  onDragStart: (e) ->
    me = this
    me.dragging = true
    me.dd.constrainTo me.el,
      right: me.diff

    return

  #Determine if the handle has been dropped > half way into the other
  #position. Toggle if so or move the handle back to the original position
  #if not.
  
  #@private
  onDragEnd: (e) ->
    me = this
    hc = (me.handle.getLeft(true) + me.handle.getRight(true)) / 2
    cc = (me.el.getLeft(true) + me.el.getRight(true)) / 2
    next = hc > cc
    (if (me.state isnt next) then me.toggle() else me.moveHandle(next))
    me.dragging = false
    return

  #Adjust the label and span positions with the handles.
  #@private
  
  onDrag: (e) ->
    me = this
    su = Corefw.util.Startup
    p = me.handle.getLeft(true) - me.rightside
    p = (if (me.handle.getLeft(true) is me.rightside) then 0 else p - me.diff3)
    if su.getThemeVersion() is 2
      if me.state
        me.onLabel.setStyle
          color: '#2B2B2B',
          backgroundColor: '#CCF2FC'
          borderRight: '1px solid #b5b6b7'
        me.offLabel.setStyle
          color: '#b6b7b9',
          backgroundColor: '#fff'
          borderLeft: 0
      else
        me.onLabel.setStyle
          color: '#b6b7b9',
          backgroundColor: '#fff'
          borderRight:0
        me.offLabel.setStyle
          color: '#2B2B2B',
          backgroundColor: '#CCF2FC'
          borderLeft: '1px solid #b5b6b7'
    else
      me.onLabel.setStyle marginLeft: p + "px"
    return

  #If not dragging toggle.
  #@private
  onMouseUp: ->
    @toggle()  unless @dragging
    return

  #Transition to the next state.
  toggle: ->
    me = this
    next = not @state
    next = (if me.state then me.onText else me.offText)  unless me.booleanMode
    if me.fireEvent("beforechange", me, next) isnt false
      me.state = not me.state
      me.moveHandle me.state, Ext.bind(me.fireEvent, me, [
        "change"
        me
        me.getValue()
      ])
    else
      me.moveHandle me.state
    return

  
  #If currently disabled, enable this component and fire the 'enable' event.
  #@return {Ext.Component} this
  enable: ->
    if @disabled
      Corefw.view.form.field.toggle.ToggleSlide.superclass.enable.call this
      @registerToggleListeners()
    
    #this.thumb.enable();
    this

  #If currently enabled, disable this component and fire the 'disable'
  #event.
  #@return {Ext.Component} this
  disable: ->
    unless @disabled
      Corefw.view.form.field.toggle.ToggleSlide.superclass.disable.call this
      @unregisterToggleListeners()
    
    #this.thumb.disable();
    this

  #Registers the mouseup listener and the DD instance for the handle.
  #@private
  registerToggleListeners: ->
    me = this
    me.dd = new Ext.dd.DD(me.handle)
    me.dd.startDrag = Ext.bind(me.onDragStart, me)
    me.dd.onDrag = Ext.bind(me.onDrag, me)
    me.dd.endDrag = Ext.bind(me.onDragEnd, me)
    me.el.on "mouseup", me.onMouseUp, me
    return

  
  #Unregisters the mouseup listener and the DD instance for the handle.
  #@private
  unregisterToggleListeners: ->
    Ext.destroy @dd
    @el.un "mouseup", @onMouseUp, this
    return

  #Returns the current internal value, either text or boolean depending on
  #configured booleanMode.
  getValue: ->
    me = this
    (if me.booleanMode then me.state else ((if me.state then me.onText else me.offText)))
