Ext.define 'Corefw.util.RowEditorHelper',
	singleton: true

# fire the before event and handle data from response
	beforeEdit: (context, editor) ->
		@retrieveEditingRowData context, editor
		# back-up the record for restoring data after cancel
		context.backupData = Ext.clone context.record.data
		# handle before edit event
		# sync the proccessing
		@sendData context, 'before', false
		@disableOrEnableCells editor
		return

	retrieveEditingRowData: (context, editor) ->
		return unless context
		cm = Corefw.util.Common
		grid = context.grid
		record = context.record
		return if not grid or not record

		store = record.store
		parent = grid.up 'fieldcontainer'
		cm = Corefw.util.Common

		rowIndex = cm.findRecordIndex store, record
		return if rowIndex < 0

		if parent.xtype is "coretreegrid"
			gridData = cm.converTreeGridDataToDataList parent.cache._myProperties.allTopLevelNodes
			if gridData?.length is 0
				gridData = cm.converTreeGridDataToDataList grid.cache._myProperties.allTopLevelNodes
		else
			gridData = parent.cache._myProperties.items
			if gridData?.length is 0
				gridData = grid.cache?._myProperties.items

		gridData or= []
		currentEditingRowData = gridData[rowIndex]
		editor.currentEditingRowData = currentEditingRowData if currentEditingRowData
		return

# call back function for beforeedit event
	processDataBeforeEdit: (context) ->
		me = @
		iv = Corefw.util.InternalVar
		return (res, ev, uipath) ->
			grid = context.grid
			if grid
				if 0 > res.widgetType?.toLowerCase().indexOf("grid") or Ext.isArray res
					Corefw.util.Request.processResponseObject res, ev, uipath
					grid.isEditing = false if not grid.el
					return
				# get the current editing grid cache 
				cm = Corefw.util.Common
				parent = grid.up "fieldcontainer"
				if parent.xtype is "coretreegrid"
					gridData = cm.converTreeGridDataToDataList parent.cache._myProperties.allTopLevelNodes
					responseGridData = cm.converTreeGridDataToDataList res.allTopLevelNodes
				else
					responseGridData = res.items
					gridData = parent.cache._myProperties.items
				record = context.record
				store = grid.getStore()
				rowIndex = cm.findRecordIndex store, record
				editingRow = gridData[rowIndex]
				newRowData = responseGridData[rowIndex]
				editable = if newRowData.hasOwnProperty 'editable' then newRowData.editable else true
				isNotEditable = newRowData.readOnly or not editable
				iv.setByNameProperty 'roweditor', 'cancelEdit', isNotEditable
				# update the new properties to current editing row cache: disabledHeaders,validations
				if editingRow
					editingRow.disabledHeaders = newRowData.disabledHeaders
					editingRow.enabledHeaders = newRowData.enabledHeaders
					editingRow.validations = newRowData.validations
					editingRow.messages = newRowData.messages
				#editingRow.tooltipValue = newRowData.tooltipValue
				if res.uipath = uipath
					props = Corefw.util.Uipath.uipathToComponent(uipath).cache._myProperties
					props.allContents = res.allContents
				me.converDateField res.allContents, newRowData.value
				me.bindDataForComboboxes context, newRowData
				# now new row data is back form server
				# we should merge it to record
				record.raw._myProperties.messages = newRowData.messages
				record.raw._myProperties.tooltipValue = newRowData.tooltipValue
				record.raw._myProperties.cssClassList = newRowData.cssClassList
				record.raw._myProperties.cellCssClass = newRowData.cellCssClass
				me.updateRecord record, newRowData.value
				if grid.updateItemDecorate?
					grid.updateItemDecorate record
				grid.setLoading false
				return

# correct the data value
	converDateField: (columnDefs, itemValue) ->
		dateCols = columnDefs.filter (v)->
			return v.type is 'DATE' or v.type is 'MONTH_PICKER'
		for col in dateCols
			dataIndex = col.index + ''
			dataValue = itemValue[dataIndex]
			if typeof dataValue is 'number'
				itemValue[dataIndex] = new Date dataValue

		date = 'DATESTRING'
		dateCols = columnDefs.filter (v)->
			return v.type is date
		for col in dateCols
			dataIndex = col.index + ''
			dataValue = itemValue[dataIndex]
			if typeof dataValue is 'string'
				itemValue[dataIndex] = Ext.Date.parse dataValue, 'Y-m-d H:i:s'

		return

	startEdit: (editor, columnHeader)->
		context = editor.context
		record = context.record
		form = editor.form
		# do some preparing works
		@correctValueToGridPickers editor, record
		@refocusOnCorrectField form, columnHeader
		@addMoreActionsToRowEditor editor
		# updateRecord and reset funtion in form are not match our complex processing requirements
		# so disable them on here, will use the helper.updateRecord functon to instead of.
		me = @
		form.updateRecord = ->
			me.updateRecord editor.context.record, me.getFormValues editor.getForm()
			return form
		form.reset = ->
		editor.hideToolTip()
		editor.updateButton editor.isValid()
		return

	cancelEdit: (context) ->
		context.record.isEditing = false
		if context.grid?.skipCancelEditing
			return
		@sendData context, 'cancel'
		return

# do some addtional actions to editor. such as validation , disable cells or something else
	addMoreActionsToRowEditor: (editor) ->
		context = editor.context
		return unless context
		record = context.record
		return if not context or not record
		currentEditingRowData = editor.currentEditingRowData
		return if not currentEditingRowData
		context.view.body = context.view if not context.view.body # fix for getOffsetsTo issue
		@bindEditorUIMessages editor
		newFieldValidationMap = currentEditingRowData.validations or {}
		errors = currentEditingRowData.messages?.ERROR or {}
		@bindValidatorToFields editor, newFieldValidationMap, errors
		return

#bind ui message to grid column editors
	bindEditorUIMessages: (editor) ->
		currentEditingRowData = editor.currentEditingRowData
		itemWarnings = currentEditingRowData.messages?.WARNING
		textEditors = editor.query "textfield[hidden=false]"
		for textEditor in textEditors
			textEditor.clearMessages()
			path = textEditor.pathString
			if not path or (editorWarnings = (itemWarnings and itemWarnings[path]) or []).length < 1
				continue
			editorWarnings = editorWarnings.join '<br>'
			textEditor.setActiveWarning editorWarnings
		return

	correctValueToGridPickers: (editor, record)->
		editor.query('roweditorgridpicker').forEach (picker)->
			fieldValue = record.get picker.name
			picker.setPickValue fieldValue

# dynamically bind combobox store values
	bindDataForComboboxes: (context, newRowItem)->
		comboboxes = context.grid.rowEditor.editor.query 'comboboxfield'
		validValues = newRowItem.validValues
		comboboxes.forEach (c)->
			if comboValues = validValues[c.pathString]
				c.setComboValues comboValues
			return
		return

	updateFieldValueFromResponse: (roweditor, newRowItem) ->
		return if not roweditor or not roweditor.context
		iv = Corefw.util.InternalVar
		# stop any event during updating value for fields
		iv.setByNameProperty 'roweditor', 'suspendChangeEvents', true
		form = roweditor.form
		grid = roweditor.context.grid
		cm = Corefw.util.Common
		newValues = newRowItem.value
		comboboxValueMap = newRowItem.validValues
		fields = form.getFields()
		findField = (pathString) ->
			fields.findBy (f) ->
				f.pathString is pathString
		for key, validValues of comboboxValueMap
			field = findField key
			v = field.getValue()
			field?.setComboValues validValues
			field.setValue v

		for key, data of newValues
			field = form.findField key
			continue if not field
			field.suspendEvents false
			isLookupable = false
			fieldType = field.xtype
			if fieldType is 'displayfield' # fixed issues for setting value to dateString or date column if it is a display field in row editor
				columnType = field.column?.cache?._myProperties.corecolumntype
				if columnType is 'datestring' or columnType is 'date'
					fieldType = 'datefield'
			switch (fieldType)
				when 'displayfield', 'comboboxfield'
					isLookupable = field.isLookupable?()
					if isLookupable or fieldType is 'displayfield'
						displayValue = cm.getDisplayValue data
					data = cm.getValue data
				when 'roweditorgridpicker'
					# magic flag from GridPickerWindow#select
					# TODO refactor grid picker, remove magic flags
					field.selChanging = false if field.selChanging
					field.addComboValue data
				when 'datefield', 'coredatefield'
					if Ext.isEmpty data
						break
					[column] = grid.columns.filter (c) ->
						if c.dataIndex is key then true else false
					props = column.cache._myProperties
					corecolumntype = props.corecolumntype
					if corecolumntype is 'datestring'
						format = 'Y-m-d H:i:s'
					else
						format = field.format
					if typeof data is 'number'
						data = new Date data
					else
						data = Ext.Date.parse data, format
					continue if format and (Ext.Date.format(field.getValue(), format) is Ext.Date.format(data, format))
					newValues[key] = data
				when'coremonthpicker'
					data = new Date data if not Ext.isEmpty data

			field.setValue data
			if field.xtype is 'corenumberfield' and field.focused
				field.setRawValue field.getValue()
				delete field.focused
			if isLookupable or fieldType is 'displayfield'
				field.setRawValue displayValue
			field.resumeEvents()
#		roweditor.context.serverData = newRowData or {}
		iv.setByNameProperty 'roweditor', 'suspendChangeEvents', false
		return

	bindHistoryInfoToCombobox: (editor, headers, rowItem)->
		combos = editor.query("combobox")
		findMatchHeader = (combo)->
			result = null;
			Ext.each headers, (header)->
				if header.pathString is combo.pathString
					result = header
					return false
				return
			return result
		Ext.each combos, (combo)->
			header = findMatchHeader combo
			historyInfo = if rowItem.historyInfo then rowItem.historyInfo else header.historyInfo
			if historyInfo
				combo.historyInfo = historyInfo
		return

# dynamicly binding the validator to each field
	bindValidatorToFields: (editor, newFieldValidationMap, errors) ->
		fields = editor.form.getFields().items
		context = editor.context
		parentCache = context.grid.up('fieldcontainer').cache
		allContents = parentCache._myProperties.allContents
		fieldValidationMaps = {}
		defaultValidator = ->
			return true
		for columnCache in allContents
			path = columnCache.path or columnCache.pathString
			originalFieldValidations = columnCache.validations or []
			newFieldValidation = newFieldValidationMap[path] or []
			if newFieldValidation and newFieldValidation.length > 0
				originalFieldValidations = Ext.Array.merge originalFieldValidations, newFieldValidation
			if originalFieldValidations and originalFieldValidations.length > 0
				fieldValidationMaps[path] = originalFieldValidations

		for field in fields
			validations = fieldValidationMaps[field.pathString] or fieldValidationMaps[field.id] or []
			field.validator = defaultValidator
			if validations.length or errors[field.pathString]?.length
				field.validator = @createValidator editor, field, validations, errors
			else
				@cleanEmptyText field
		return

	disableOrEnableCells: (editor) ->
		form = editor.form
		disabledHeaders = editor.currentEditingRowData?.disabledHeaders || []
		enabledHeaders = editor.currentEditingRowData?.enabledHeaders || []
		@resetCellDisabledState form
		return if disabledHeaders.length is 0 and enabledHeaders.length is 0
		allFields = form.getFields().items
		for field in allFields
			if disabledHeaders.indexOf(field.pathString) isnt -1 or disabledHeaders.indexOf(field.id) isnt -1
				field.disable()
			if enabledHeaders.indexOf(field.pathString) isnt -1 or enabledHeaders.indexOf(field.id) isnt -1
				field.enable()
		return

	resetCellDisabledState: (form)->
		allFields = form.getFields().items
		for field in allFields
			if not field.hasOwnProperty 'origDisabled'
				field.origDisabled = field.disabled
			field.setDisabled field.origDisabled

# dynamicly create editor by new validations
	createValidator: (editor, field, validationRules, errors) ->
		field.errMsg = {}
		me = @
		return (value) ->
			validateResult = me.validateByErrorMessage editor, field, value, errors
			if validateResult.isValid is true
				validateResult = me.validateValueByValidationRules @, value, validationRules
			me.cancelValidationTooltip editor
			return validateResult.isValid || validateResult.errMsg

# indicate the validation is failed if the field name matched in error messages
	validateByErrorMessage: (editor, field, value, errors) ->
		return if not errors
		validateResult = {'isValid': true, 'errMsg': null}
		errorMessage = errors[field.pathString] || []
		if errorMessage?.length > 0
			validateResult.isValid = false
			validateResult.errMsg = errorMessage.join '<br>&nbsp;'
		@cancelValidationTooltip editor
		return validateResult

# the core validation funtions
	validateValueByValidationRules: (field, value, validations) ->
		validateResult = {'isValid': true, 'errMsg': null}
		for valdtn in validations
			if valdtn.constraintName is "FieldRegex"
				reg = eval '/' + valdtn.constraintMap.pattern + '/'
				if not reg.test value
					validateResult.errMsg = valdtn.constraintMessage
					validateResult.isValid = false
					break
			else if valdtn.constraintName is "FieldNotNull"
				if Ext.isEmpty value
					emptyText = "required"
					field.emptyText = emptyText
					@setPlaceHolderValue field, emptyText
					validateResult.errMsg = valdtn.constraintMessage
					validateResult.isValid = false
					break
			else if valdtn.constraintName is "FieldLength"
				minLength = valdtn.constraintMap.minLength
				maxLength = valdtn.constraintMap.maxLength
				if !value and minLength is 0
					break
				if minLength and value.length < minLength or maxLength and value.length > maxLength
					validateResult.errMsg = valdtn.constraintMessage
					validateResult.isValid = false
					break
		return validateResult

# hide the tooltip when validations in field is failed
	cancelValidationTooltip: (editor) ->
		hide = Ext.Function.createDelayed ->
			editor.hideToolTip()
			return
		, 1
		hide();
		return

# clean the place holder value when validations in field is pass or no validations in field
	cleanEmptyText: (field) ->
		if field.emptyText is 'required'
			field.emptyText = ''
			field.applyEmptyText()
			@setPlaceHolderValue field, ''
		return

	setPlaceHolderValue: (field, value)->
		e = Ext.DomQuery.select('input', field.el.dom)[0]
		e.placeholder = value if e?
		return

# Focus the cell on start edit based upon the current context
	refocusOnCorrectField: (form, columnHeader) ->
		fieldId = columnHeader.getEditor().id
		field = form.findField fieldId
		if field and not field.isDisabled()
			field.suspendEvents false
			field.focus false, 1
			field.resumeEvents()
		return

# stop starting the editor by entitlement flag 'readOnly'
	processProhibited: (grid, record) ->
		cm = Corefw.util.Common
		store = record.store
		rowIndex = cm.findRecordIndex store, record
		isProhibited = cm.processProhibited grid
		props = grid?.up('fieldcontainer')?.cache?._myProperties or {}

		data = if props.widgetType is "TREE_GRID" then cm.converTreeGridDataToDataList props.allTopLevelNodes else props.items
		isItemReadOnly = data[rowIndex]?.readOnly
		if isItemReadOnly or isProhibited
			return true
		else
			return false

# init the value getters for different complex component
	valueGetter:
		roweditorgridpicker: (field)->
			cm = Corefw.util.Common
			vals = []
			valueMap = field.valueMap
			currValues = field.value
			if Ext.isArray(currValues)
				for currVal in currValues
					vals.push
						displayValue: cm.getKeyByValue(currVal, valueMap)
						value: currVal
			else
				vals.push
					displayValue: cm.getKeyByValue(currValues, valueMap)
					value: currValues

			if field.multiSelect
				vals
			else
				vals[0]

		comboboxfield: (field) ->
			displayValue: field.getRawValue()
			value: field.getValue()
# init the value comparator getters for different complex component
	valueComparator:
		roweditorgridpicker: (newValue, oldValue, multiSelect) ->
			if multiSelect
				if newValue.length isnt oldValue.length
					return false
				else
					for v , i in newValue
						return false if not (v.value is oldValue[i].value)
				return true
			else
				newValue.value is oldValue.value

		comboboxfield: (newValue, oldValue) ->
			if Ext.isObject newValue
				newValue = newValue.value or ''
			if Ext.isObject oldValue
				oldValue = oldValue.value or ''
			return newValue is oldValue
		coremonthpicker: (newValue, oldValue) ->
			mFormat = (d) ->
				month = d.getMonth() + 1
				d.getFullYear() + (if month < 10 then '-0' else '-') + month
			if newValue instanceof Date
				newValue = mFormat newValue
			if oldValue instanceof Date
				oldValue = mFormat oldValue
			newValue is oldValue
		datefield: (newValue, oldValue) ->
			dFormat = (d) ->
				d.getFullYear() + '-' + (d.getMonth() + 1) + '-' + d.getDate()
			if newValue instanceof Date
				newValue = dFormat newValue
			if oldValue instanceof Date
				oldValue = dFormat oldValue
			newValue is oldValue
	# since original updateRecord function in form is not suitable for handling complex value
	# we override a new updateRecord of our own
	updateRecord: (record, values) ->
		changedValues = {}
		getValue = (value) ->
			if Ext.isObject(value) and value.hasOwnProperty 'value'
				return value.value
			else if Ext.isDate value
				return value.getTime()
			else if Ext.isArray value
				return (value.map (v) -> v.value or v).sort().join ','
			else
				return value
		for key, value of values
			continue if value is undefined
			oldValue = getValue record.get key
			newValue = getValue value
			if oldValue isnt newValue
				if (Ext.isDate record.get key) and Ext.isNumber value
					value = new Date value
				changedValues[key] = value
		record.beginEdit()
		record.set(changedValues)
		record.endEdit()
		return

	getFormValues: (form) ->
		fields = form.getFields().items
		fieldValues = form.getFieldValues()
		for field in fields
			value = fieldValues[field.name]
			if value and field.getDisplayValue
				displayValue = field.getRawValue()
				fieldValues[field.name] =
					displayValue: displayValue
					value: value
		return fieldValues
	# send row editor data to server,can hanlder updating or canceling by indicating evt param
	sendData: (context, evt, isAsync = true) ->
		evtMap = @evtMap or {'update': 'ONAFTEREDIT', 'cancel': 'ONCANCELEDIT', 'before': 'ONBEFOREEDIT'}
		grid = context.grid
		if grid.xtype is 'coretreebase'
			dataGrid = context.grid.up 'coretreegrid'
			root = grid.store.tree.root
			Corefw.util.Common.traverseTreeStore root, (record) ->
				record.isEditing = false
				return
		else
			dataGrid = context.grid.up 'coreobjectgrid'
			dataItems = grid.store.data.items
			Ext.Array.forEach dataItems, (r) ->
				r.isEditing = false
				return

		context.record.isEditing = true
		updateURL = dataGrid.eventURLs[evtMap[evt]]
		uipath = dataGrid.uipath
		rq = Corefw.util.Request
		url = rq.objsToUrl3 updateURL
		return unless url
		postData = dataGrid.generatePostData()

		callback = if evt is 'before' then @processDataBeforeEdit(context) else rq.processResponseObject
		rq.sendRequest5 url, callback, uipath, postData, undefined, undefined, undefined, undefined, undefined, isAsync
		return