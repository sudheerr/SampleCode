Ext.define 'Corefw.controller.RowEditor',
	extend: 'Ext.app.Controller'

	init: ->
		@control
		# check box--------------------------------------
			'roweditor checkbox[columnONCHANGEevent]':
				change: @onEditorCheckboxChange
			'roweditor checkbox[columnONCHECKCHANGEevent]':
				change: @onEditorCheckboxCheckChange
		# text field-------------------------------------
			'roweditor textfield[columnONCHANGEevent]':
				change: @onEditorTextfieldChange()
			'roweditor textfield[columnONBLURevent]':
				blur: @onEditorTextfieldBlur
		# combobox---------------------------------------
			'roweditor combobox[columnONSELECTevent]':
				select: @onEditorComboBoxSelect
			'roweditor combobox[columnONCHANGEevent]':
				change: @onEditorComboBoxChange
		# month picker-----------------------------------
			'roweditor coremonthpicker[columnONSELECTevent]':
				select: @onEditorMonthPickerChange
			'roweditor coremonthpicker[columnONCHANGEevent]':
				change: @onEditorMonthPickerChange

			'roweditor field':
				focus: (comp) ->
					grid = comp.up 'grid'
					if grid
						[currentColunmn] = grid.columns.filter (c) ->
							return c.dataIndex is comp.name
						if currentColunmn and restoreInfo = Corefw.util.InternalVar.getByNameProperty 'roweditor', 'restoreinfo'
							restoreInfo.columnIndex = grid.columnManager.getHeaderIndex currentColunmn
						return
				change: (comp, newValue) ->
					# for changing the update button statusdynamically
					editor = comp.up 'roweditor'
					editor.updateButton editor.isValid()

			'grid':
				beforedestroy: @onEditorHostBeforeDestory
			'treepanel':
				beforedestroy: @onEditorHostBeforeDestory
		return
	onEditorHostBeforeDestory: (host) ->
		console.log 'grid/tree destory'
		if host.isEditing
			rowEditor = host.rowEditor
			return unless rowEditor
			rowEditor.hideMask()
		return

	# common

	# month picker-------------------------------------------
	onEditorMonthPickerChange: (comp, newValue, oldValue) ->
		@fireEditorEvent comp, 'ONCHANGE', true
		return

	# check box----------------------------------------------
	onEditorCheckboxChange: (comp) ->
		@fireEditorEvent comp, 'ONCHANGE', true
		return
	onEditorCheckboxCheckChange: (comp) ->
		@fireEditorEvent comp, 'ONCHECKCHANGE', true
		return

		# text field---------------------------------------------
	onEditorTextfieldChange: ->
		task = new Ext.util.DelayedTask @fireEditorEvent, this
		return (comp, newValue, oldValue) ->
			return if (comp.xtype is 'comboboxfield' or comp.xtype is 'coremonthpicker' or comp.xtype is 'coremonthpickerfield')
			task.delay 500, null, null, [comp, 'ONCHANGE', true]

	onEditorTextfieldBlur: (comp, event) ->
		@fireEditorEvent comp, 'ONBLUR', true, event
		return
	# combobox-----------------------------------------------
	onEditorComboBoxSelect: (comp) ->
		# for gridpicker, disable onchange event when it fires select event
		# otherwise, two events will be fired at the same time, and it will cause event response order issue.
		compXtype = comp.xtype
		if compXtype is 'roweditorgridpicker'
			comp.suspendEvent 'change'

		@fireEditorEvent comp, 'ONSELECT', true, event

		# Enable change event again after 1s.
		# when select record on gridpickerwindow,
		# and its gridpicker suspendChangeBuffer is enabled,
		# must use delayed resume event,
		# otherwise change event still be triggered somehow.
		if compXtype is 'roweditorgridpicker'
			resumeChangeEvent = Ext.Function.createDelayed ->
				comp.resumeEvent 'change'
				return
			, 1000
			resumeChangeEvent()
		return
	onEditorComboBoxChange: (comp) ->
		@fireEditorEvent comp, 'ONCHANGE', true, event
		return

	fireEditorEvent: (comp, evtType, forcedUpdateRec, event) ->
		return if (not comp.el) or comp.isDisabled()
		console.log 'fire the event on roweditor'
		iv = Corefw.util.InternalVar
		rq = Corefw.util.Request
		parent = comp.up('grid') or comp.up('treepanel')
		# stop firing event if roweditor told us it should suspend changing events
		return if iv.getByNameProperty 'roweditor', 'suspendChangeEvents'

		source = comp.column
		eventURL = source.cache._myProperties.eventURLs?[evtType]
		return if not eventURL

		# stop firing any event during processing response
		iv.setByNameProperty 'roweditor', 'suspendChangeEvents', true

		editor = comp.up 'roweditor'
		if evtType is 'ONBLUR'
			editor.updateButton true
		else
			editor.updateButton false
		record = editor.context?.record
		form = editor.getForm()
		if forcedUpdateRec and record
			form.updateRecord()
		parentField = parent.up 'fieldcontainer'
		uipath = parentField.uipath
		if evtType is 'ONLOOKUP'
			postData = null
			if not comp.isNotFirstLookUp
				comp.isNotFirstLookUp = true
				lookUpString = ''
			else
				lookUpString = comp.getRawValue()
			url = rq.objsToUrl3 eventURL, null, lookUpString
		else
			postData = parentField.generatePostData()
			url = rq.objsToUrl3 eventURL
			@applyChangedValue postData, form, parent.editingPlugin.recordIndex
		errMsg = 'Did not receive a valid response'
		method = 'POST'
		callbackMethod = @processEditorEvent editor, comp
		rq.sendRequest5 url, callbackMethod, uipath, postData, errMsg, method
		iv.setByNameProperty 'roweditor', 'suspendChangeEvents', false
		return
	applyChangedValue: (postData, form, rowIndex) ->
		return unless Ext.isNumber rowIndex
		postItem = postData.items[rowIndex]
		postItem.changed = true
		postItem.editing = true
		postValues = postData.items[rowIndex].value
		fieldValues = form.getFieldValues()
		isEmpty = Ext.isEmpty
		isBoolean = Ext.isBoolean
		isString = Ext.isString
		isDate = Ext.isDate
		isNumber = Ext.isNumber
		for key, value of fieldValues
			postValue = null
			postValue = postValues[key]
			continue if isEmpty value
			if isBoolean(postValue) and (value in ['true', 'false'])
				value = if value is 'true' then true else false
			else if isString(postValue) and isDate(value)
				value = Ext.Date.format value, 'Y-m-d H:i:s'
			else if isNumber(postValue) and isDate(value)
				value = value.getTime()
			else if value and value.hasOwnProperty('value')
				value = value.value
			postValues[key] = value if postValue isnt value
		return
#	to extract current editing grid response data from different kind of response
	extractGridResponse: (uipath, responseObj) ->
		if responseObj.uipath is uipath
			gridResp = responseObj
		else if Ext.isArray responseObj
			[gridResp] = responseObj.filter (r) ->
				return uipath is r.uipath
		else
			gridResp = @traverseResponseTree uipath, responseObj
		if not gridResp
			gridResp =
				isSkip: true
		gridResp.isIgnored = true
		return gridResp

#	deeply traverse response tree to find current editing grid response data
	traverseResponseTree: (uipath, responseObj) ->
		if responseObj.uipath is uipath
			return responseObj
		allContents = responseObj.allContents
		response =
			isSkip: true
		for subResponse, index in allContents
			response = @traverseResponseTree uipath, subResponse
			if response
				break
		return response

	processEditorEvent: (roweditor) ->
		cm = Corefw.util.Common
		helper = Corefw.util.RowEditorHelper
		controller = this
		iv = Corefw.util.InternalVar
		grid = roweditor.context?.grid
		editingPlugin = roweditor.editingPlugin
		editingPlugin.isProcessingEvent = true
		if not grid
			return ->
		parent = grid.ownerCt
		return (responseObj, ev, triggerUipath) ->
			editingPlugin.isProcessingEvent = false
			context = roweditor.context
			return unless parent or context or not roweditor.isVisible()
			roweditor.updateButton true
			if not roweditor.el
				editingPlugin.hideMask?()
				return
			gridResp = controller.extractGridResponse parent.uipath, responseObj
			Ext.defer -> Corefw.util.Request.processResponseObject responseObj, 1
			return if gridResp.isSkip

			if gridResp.cancelEditing
				grid.isEditing = false
				cacheObject = Corefw.util.Cache.parseJsonToCache(gridResp)
				name = parent.cache._myProperties.name
				gridCache = cacheObject[name]
				grid.updateFromCache? gridCache
				editingPlugin?.cancelEdit?()
				return

			rowIndex = editingPlugin.recordIndex
			props = parent.cache._myProperties
			props.allContents = gridResp.allContents
			if gridResp.widgetType is 'TREE_GRID'
				newRowItems = cm.converTreeGridDataToDataList gridResp.allTopLevelNodes
				props.allTopLevelNodes = gridResp.allTopLevelNodes
			else
				props.items = gridResp.items
				newRowItems = gridResp.items

			newRowItem = newRowItems[rowIndex]
			helper = Corefw.util.RowEditorHelper
			editingPlugin.suspendChangeEvents = true
			helper.updateFieldValueFromResponse roweditor, newRowItem
			helper.bindHistoryInfoToCombobox roweditor, props.allContents, newRowItem
			helper.retrieveEditingRowData context, roweditor
			helper.disableOrEnableCells roweditor
			helper.addMoreActionsToRowEditor roweditor
			editingPlugin.suspendChangeEvents = false
			isValid = roweditor.isValid()
			isValid and helper.updateRecord context.record, newRowItem.value
			roweditor.updateButton isValid
			# resume event processing
			iv.setByNameProperty 'roweditor', 'suspendChangeEvents', false
			if isValid and editingPlugin.shouldResumeUpdating
				editingPlugin.completeEdit()
			return