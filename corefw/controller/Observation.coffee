Ext.define 'Corefw.controller.Observation',
	extend: 'Ext.app.Controller'
	init: ->
		@Observer = Corefw.util.Observer
		@control
			'corecompositeelement, coreelementform, coretoolbar':
				afterrender: @addObservedTarget

			'coretoolbar[rendered] field':
				change: @markDirty

			'coreelementform[rendered] field':
				change: @markDirty

			'component[cache][uipath]':
				afterrender: @registerObserver

	addObservedTarget: (comp) ->
		@Observer.addTarget comp.uipath
		return

	registerObserver: (comp) ->
		events = comp.cache._myProperties?.events
		(Ext.isObject events) and events = events._ar
		events and @Observer.registerObserver comp.uipath, events
		return

	markDirty: (comp) ->
		uip = Corefw.util.Uipath
		parentKey = uip.uipathToParentUipath comp.uipath
		@Observer.updateState @Observer.States.DIRTY, parentKey
		return