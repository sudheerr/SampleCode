Ext.define 'Corefw.view.grid.gridpick.GridPicker',
	extend: 'Ext.form.field.ComboBox'
	xtype: 'coregridpicker'
	cls: 'gridpicker'
	minChars: 2
	editable: false
	firstLookup: true
	queryMode: 'local'
	checkChangeBuffer: 500
	initComponent: ->
		me = @
		su = Corefw.util.Startup
		me.listeners = me.listeners or {}
		Ext.apply me.listeners, @addListeners
		props = me.cache._myProperties
		if Corefw.view.form.field.ComboboxField.isLookupable props
			me.addCls 'citiriskLookup'
			me.setHideTrigger true
		me.setEditable Corefw.view.form.field.ComboboxField.isEditable props
		cm = Corefw.util.Common
		me.callParent arguments
		me.setRawValue cm.getDisplayValue props
		me.postValue = cm.getValue props
		me.coretype = 'corefield'
		if su.getThemeVersion() is 2
			if not props.lookupable
				me.fieldStyle =
					borderRightWidth: '0px'
				@triggerBaseCls = 'formtriggericon'
				@triggerCls = 'combotrig'
		return
	addListeners:
		blur: (me, e)->
			#if the gridwindow get focus,should disable onBlur event
			if me.gridwindow?.el.dom.contains(e.target)
				return false
		change: (me, newVal, oldVal) ->
			if @selChanging
				delete @selChanging
				return
			if @isLookupable()
				delete @postValue
				@loadData newVal
			return
		focus: (me)->
			#props = @cache._myProperties
			if not @inited
				@initGridwindow()
			else if @gridwindow.isHidden()
				if @firstLookup
					lookup = ''
					@firstLookup = false
				else
					lookup = @getRawValue()
				@loadData(lookup, ()->
					me.showGridWindow()
					return
				)
			return
		resize: (me, width, height, oldWidth, oldHeight)->
			if me.gridwindow and not me.gridwindow.isHidden()
				me.showGridWindow()
			return
	initGridwindow: ()->
		me = @
		props = @cache._myProperties
		#body = me.up('form').body
		@gridwindow = Ext.create 'Corefw.view.grid.gridpick.GridPickerWindow',
			parentField: me
			multiSelect: props.multiSelect
		@gridwindow.hide()
		@loadData("", ()->
			me.showGridWindow()
			return
		)
		@inited = true
		return
	setPickValue: (val)->
		cm = Corefw.util.Common
		displayValue = cm.getDisplayValue val
		value = cm.getValue val
		@setRawValue displayValue
		@postValue = value
		return
	setValue: (val)->
		return
	loadData: (searchString, callbackFn)->
		if not searchString
			searchString = ''
		rq = Corefw.util.Request
		props = @cache._myProperties
		me = @
		win = me.gridwindow
		if not win
			return
		if @isLookupable()
			callback = (respObj)->
				if not me.isVisible()
					return
				win.showData respObj
				win.setSelectedValue me.postValue
				if callbackFn
					callbackFn()
				return
			url = rq.objsToUrl3 @eventURLs['ONLOOKUP'], null, searchString
			rq.sendRequest5 url, callback, @uipath
		else
			win = @gridwindow
			if not @inited
				win.showData props
			win.setSelectedValue @postValue
			if callbackFn
				callbackFn()
		return

	getPostValue: ->
		return if @postValue is undefined then @getRawValue() else @postValue
	hideGridWindow: ()->
		@gridwindow.hide()
		@firstLookup = true
		return
	showGridWindow: () ->
		me = @
		win = me.gridwindow

		win.show()
		return
	isLookupable: ()->
		return (Corefw.view.form.field.ComboboxField.isLookupable @) or (Corefw.view.form.field.ComboboxField.isLookupable @cache?._myProperties)
	isEditable: ()->
		return (Corefw.view.form.field.ComboboxField.isEditable @) or (Corefw.view.form.field.ComboboxField.isEditable @cache?._myProperties)
	onDestroy: ->
		@callParent arguments
		if @gridwindow
			@gridwindow.destroy()
			delete @gridwindow
		delete @inited
		return
	generatePostData: ->
		value = @postValue
		displayValue = @getRawValue()
		fieldObj =
			name: @name
			value: if Ext.isEmpty(value) then "" else value
			displayValue: if Ext.isEmpty(displayValue) then "" else displayValue
		return fieldObj
