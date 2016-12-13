Ext.define 'Corefw.view.grid.gridpick.RowEditorGridPicker',
	extend: 'Ext.form.field.ComboBox'
	xtype: 'roweditorgridpicker'
	cls: 'gridpicker'
	minChars: 2
	editable: false
	lookupable: false
	gridProperties:
		items: []
	validValues: {}
	displayValue: ""
	value: ""
	firstLookup: true
	valueMap: {}
	displayValueSeparator: ","
	queryMode: 'local'
	checkChangeBuffer: 500
	initComponent: ->
		@listeners = @listeners || {}
		Ext.apply(@listeners, @addListeners)
		if Corefw.view.form.field.ComboboxField.isLookupable @
			@addCls 'citiriskLookup'
			@setHideTrigger true
		@setEditable Corefw.view.form.field.ComboboxField.isEditable @
		cm = Corefw.util.Common
		@callParent arguments
		@setRawValue cm.getDisplayValue @
		@value = cm.getValue @
		@initGridwindow()
		return


	setComboValues: (value)->
		cm = Corefw.util.Common
		@validValues = value
		me = @
		setMap = (val)->
			_value = cm.getValue val
			displayValue = cm.getDisplayValue val
			me.valueMap[displayValue] = _value
			return
		if Ext.isArray value
			for val in value
				setMap val
		else
			setMap value
		return

	addComboValue: (comboValue) ->
		if Ext.isString comboValue
			return
		if not Ext.isArray comboValue
			comboValue = [comboValue]
		for val in comboValue
			cm = Corefw.util.Common
			value = cm.getValue val
			displayValue = cm.getDisplayValue val
			@valueMap[displayValue] = value
		return

	addListeners:
		blur: (me, e) ->
			#if the gridwindow get focus,should disable onBlur event
			if me.gridwindow?.el?.dom.contains(e.target)
				return false
		change: (me, newVal, oldVal) ->
			if @selChanging
				delete @selChanging
				return
			if @isLookupable()
				@loadData @getRawValue()
				delete @value
			return
		focus: (me) ->
			if me.isLookupable()
				lookup = @getRawValue()
				@loadData(lookup, ->
					me.showGridWindow()
					return
				)
			return
		resize: (me, width, height, oldWidth, oldHeight)->
			if me.gridwindow and not me.gridwindow.isHidden()
				me.showGridWindow()
			return
# override: show grid window
	onTriggerClick: ->
		#		@callParent arguments
		me = @
		if not me.isLookupable()
			if not me.isDataLoaded
				@loadData()
				me.isDataLoaded = true
			me.showGridWindow()

	getValue: ->
		value = this.value
		if Ext.isEmpty value
			return this.getRawValue()
		return value
	initGridwindow: ()->
		me = @
		@gridwindow = Ext.create 'Corefw.view.grid.gridpick.GridPickerWindow',
			parentField: me
			multiSelect: @multiSelect

		return
	setPickValue: (val)->
		cm = Corefw.util.Common
		displayValue = cm.getDisplayValue val
		value = cm.getValue val
		@setRawValue displayValue
		@value = value
		if @valueMap[displayValue] is undefined
			@valueMap[displayValue] = value
		@validate()
		return
	setValue: (val)->
		cm = Corefw.util.Common
		win = @gridwindow
		if win
			vals = win.setSelectedValue val
			valIndexes = []
			@value = cm.getValue val

			for sel in vals
				valIndexes.push sel.index
			if valIndexes.length
				@setPickValue win.getValueByIndex valIndexes
			else
				if Ext.isObject(val) or (Ext.isString(val) and @_getDisplayValue(val) is '')
					@setRawValue cm.getDisplayValue val
				else
					@setRawValue @_getDisplayValue(val)
		return
	_getDisplayValue: (value)->
		if not Ext.isArray value
			value = [value]
		cm = Corefw.util.Common
		result = []
		for p of @valueMap
			for val in value
				if @valueMap[p] is cm.getValue val
					result.push p
		return result.join @displayValueSeparator
	showGridData: (props)->
		gridProperties = props?.gridPicker
		if gridProperties
			@gridProperties = gridProperties
		validValues = props?.validValues
		if validValues
			@setComboValues validValues

		win = @gridwindow

		win.showData(
			gridPicker: @gridProperties
			validValues: @validValues
		)
		return
	loadData: (searchString, callbackFn)->
		if not searchString
			searchString = ''
		rq = Corefw.util.Request
		me = @
		win = me.gridwindow
		if not win
			return
		if @isLookupable()
			callback = (respObj)->
				me.showGridData respObj
				win.setSelectedValue me.getValue()
				if callbackFn
					callbackFn()
				return
			url = rq.objsToUrl3 @eventURLs['ONLOOKUP'], null, searchString
			rq.sendRequest5 url, callback, @uipath
		else
			props = @cache._myProperties
			@showGridData props if @firstLookup
			win.setSelectedValue me.getValue()
			if callbackFn
				callbackFn()
		return
	hideGridWindow: ()->
		@gridwindow.hide()
		@firstLookup = true
		return
	showGridWindow: () ->
		me = @
		win = me.gridwindow
		if not win.isVisible?()
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
		return
