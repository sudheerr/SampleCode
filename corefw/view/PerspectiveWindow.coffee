Ext.define 'Corefw.view.PerspectiveWindow',
	extend: 'Ext.window.Window'
	xtype: 'coreperspectivewindow'
	mixins: ['Corefw.mixin.Perspective']
	ui: 'citiriskmodalwindow'
	autoShow: true
	autoScroll: true
	constrain: true
	coretype: 'perspective'
	modal: true
	width: '90%'
	shadow: 'drop'
	layout: 'fit'
	shadowOffset: 4

	initComponent: ->
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			@ui = 'default'
		props = @cache._myProperties
		@height = props.height if props.height
		@width = props.width if props.width
		@closable = false if not props.closable
		@draggable = false if not props.draggable
		@resizable = false if not props.resizable
		if props.position isnt 'ON_MOUSE'
			[x, y] = @calculateCentreXY props
			@x = x
			@y = y
		@addListeners()
		@callParent arguments
		return

	addListeners: ->
		@listeners = @listeners or {}
		additionalListeners =
			beforedestroy: @beforePerspectiveDestroy
			beforeclose: @beforeWindowClose
			close: @onWindowClose
			render: @onWindowRender

		Ext.apply @listeners, additionalListeners

# calculate the coodinate x,y, There are conditions:width,height,coodinateX,coodinateY to control the position and make window in the center
# if all of conditions are empty, the widonw will be located in the top left
	calculateCentreXY: (props) ->
		pageX = document.documentElement.clientWidth
		pageY = document.documentElement.clientHeight
		width = props.width or pageX
		height = props.height or pageY
		position = props.position
		coordinateX = props.coordinateX or 0
		coordinateY = props.coordinateY or 0

		switch position
			when 'ON_COORDINATE_PX'
				x = coordinateX
				y = coordinateY
			when 'ON_COORDINATE_PCT'
				x = pageX * (coordinateX / 100)
				y = pageY * (coordinateY / 100)

		x = x or (pageX - width) / 2
		x = -1 if x <= 0
		y = y or (pageY - height) / 2
		y = 0 if y < 0

		[x, y]

	processResponseObject: (obj, ev, uipath) ->
		rq = Corefw.util.Request
		uip = Corefw.util.Uipath
		me = @

		closeSelfIfResObjIsOutside = (props) ->
			respUipath = props.uipath
			perspectiveWindowOfResObj = (uip.uipathToComponent respUipath)?.up 'coreperspectivewindow'
			if not perspectiveWindowOfResObj
				# enable events on original uipath
				me.enableUEvents uipath
				me.destroy()
			return

		rq.processResponseObject obj, ev, uipath, closeSelfIfResObjIsOutside
		return

	enableUEvents: (uipath) ->
		evt = Corefw.util.Event
		uip = Corefw.util.Uipath
		evt.enableUEvent uipath, 'ONCLOSE'
		# enable onload/onclose events of its grids/trees/elements/views if have
		comp = uip.uipathToComponent uipath if uipath
		fieldContainers = comp.query "fieldcontainer, coreviewstacked, coreelementform" if comp and comp.query
		Ext.each fieldContainers, (fieldContainer) ->
			fcUipath = fieldContainer.uipath
			if not fcUipath
				return
			evt.enableUEvent fcUipath, 'ONCLOSE'
			return
		return

	beforePerspectiveDestroy: ->
		@onPerspectiveDestroy()
		return

	beforeWindowClose: ->
		uipath = @cache._myProperties.uipath
		@enableUEvents uipath
		return

	onWindowClose: ->
		iv = Corefw.util.InternalVar
		uipath = @cache._myProperties.uipath
		# enableUEvents is used somewhere else with different logic, so below part cannot be moved into
		# enable ONLOAD/ONREFRESH when popup is closed
		iv.deleteByUipathCascade uipath
		return

	onWindowRender: (window) ->
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			header = window.getHeader()
			if header.items
				items = header.items.items
				if items
					for item in items
						type = item.type
						if type is 'close'
							item.addCls "#{Ext.baseCSSPrefix}window-close-btn"
							item.setWidth 18
							item.setHeight 18
		return