Ext.define 'Corefw.controller.Field',
	extend: 'Ext.app.Controller'

	init: ->
		@control
			'combobox[isLookup]':
				change: @onIsLookupComboBoxChange
				focus: @onIsLookupComboBoxFocus
				beforeselect: @toogleComboBoxChangeEvent
				select: @toogleComboBoxChangeEvent
			'combobox[fieldONSELECTevent]':
				select: @onComboBoxSelect
			'combobox[fieldONDOUBLECLICKevent]':
				itemdblclick: @onComboBoxDblClick
			'coretreesimple[fieldONDOUBLECLICKevent] treepanel':
				itemdblclick: @onDBLClickSimpleTreeItem
			'coretreesimple[fieldONCLICKevent] treepanel':
				itemclick: @onClickSimpleTreeItem
			'coretreesimple[fieldONREDIRECTevent] treepanel':
				itemclick: @onClickSimpleTreeItemLink
			'coretreesimple[fieldONDOWNLOADevent] treepanel':
				itemclick: @onClickSimpleTreeItemLink
			'coretreemixedgrid treepanel':
				itemclick: @onClickTreeMixedGrid
				itemexpand: @onExpandOrCollapseMixedGrid
				itemcollapse: @onExpandOrCollapseMixedGrid
			'coretreemixedgrid treepanel grid':
				itemclick: @onClickTreeMixedGridItem
			'[fieldONLOADevent], [fieldONREFRESHevent]':
				afterrender: @onFieldRenderEvent
			'textfield[fieldONBLURevent]':
				blur: @onFieldBlur
			'textfield[fieldONCHANGEevent]':
				change: @onFieldChange
			'coreduallistbox[fieldONCHANGEevent]':
				change: @onFieldChange
			'textfield[fieldONFOCUSevent]':
				focus: @onFieldFocus
			'textfield[fieldONENTERKEYevent]':
				specialkey: @onFieldEnterKey
			'coreelementform field:not([fieldONFOCUSevent])':
				focus: @recordFieldFocusStatus
			'checkbox[fieldONCHANGEevent]':
				change: @onFieldCheckChange
			'checkbox':
				beforerender: @onBeforeCheck
			'[fieldONTREEEXPANDevent] treepanel':
				beforeitemexpand: @onTreeItemExpand
			'corelinkfield[fieldONCLICKevent]':
				linkclick: @onClickLink
			'corelinkfield[fieldONDOWNLOADevent]':
				linkclick: @onClickLinkToDownload
			'corelinkfield[fieldONREDIRECTevent]':
				linkclick: @onClickLinkToRedirect
			'coreiframefield[fieldONCLICKevent]':
				click: @onClickIframe
			'coreiconfield[fieldONICONCLICKevent] button':
				click: @onClickButtonIcon
			'filefield':
				change: @onFileFieldChange
			'coreradiogroup[fieldONCHANGEevent]':
				change: @onRadioGroupCheckChange
			'coreSwitchBtn[fieldONCHANGEevent]':
				change: @onRadioGroupCheckChange
			'corecheckboxgroup[fieldONCHANGEevent]':
				change: @onCheckGroupCheckChange
			'coremonthpicker':
				change: @onMonthPickerChange
			'coretreepickerwindow treepanel':
				itemclick: @onTreePickerItemClick
				select: @onTreePickerSelect
			'textfield[inputMask]':
      	keypress: @filterUserInputs
			'field':
				afterrender: @validateChanging
			'corechartfield':
				resize: @updateLegendLayout
		@initialTasks()
		return

	fieldEventFireTask: null

	initialTasks: ->
		@fieldEventFireTask = new Ext.util.DelayedTask @fieldEvent, this

	onBeforeCheck: (field, eOpts) ->
		# Adding label style for checkbox and radio button
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			if field.boxLabel
				field.boxLabelCls = 'boxLabelCls'
		return
	onFieldEnterKey: (field, e) ->
		if e.getKey() is e.ENTER
			evt = Corefw.util.Event
			@fieldEvent 'ONENTERKEY', field
			evt.enableUEvent field.uipath, 'ONENTERKEY'
		return

	filterUserInputs: (field, event) ->
		inputMask = field.inputMask
		regex = inputMask.regex
		if not regex
			return
		rawVal = field.getRawValue()
		eventTarget = event.getTarget()
		selectionStart = eventTarget.selectionStart
		selectionEnd = eventTarget.selectionEnd
		newRawVal = rawVal.substring(0,
			selectionStart) + String.fromCharCode(event.charCode) + rawVal.substring(selectionEnd)
		if field.xtype is 'corenumberfield'
			newRawVal = field.parseValueAsStr newRawVal
		pattern = new RegExp regex
		if not pattern.test newRawVal
			event.preventDefault()
		return

	updateLegendLayout: (chartfield, width, height) ->
		chart = chartfield.chart
		position = chart.legendPosition
		su = Corefw.util.Startup
		if (Ext.isEmpty chart.surface.width) or (Ext.isEmpty chart.surface.height)
			return

		if position and not chart.hasResized
			chart.hasResized = true
			chart.legend = Ext.create 'Ext.ux.chart.SmartLegend',
				position: position
				chart: chart
				boxStrokeWidth: 1
				rebuild: true

			if su.getThemeVersion() is 2
				legendConfig =
					boxStrokeWidth: 0
					boxFill: '#EBEBEB'
					itemSpacing: 0
					labelFont: '11px arial, sans-serif'

				Ext.apply chart.legend, legendConfig

			chart.legend.redraw()
			chart.redraw()
		return

	onTreepickerClickOrSelect: (parentWindow, record) ->
		parentField = parentWindow.parentField
		form = parentField.up 'form'
		# get properties for getting display value and send value
		displayField = parentWindow.tree.displayField
		displayValue = record.get displayField
		sendValueField = parentWindow.tree.valueField
		sendValue = record.get sendValueField

		parentField = parentWindow.parentField
		delete parentField.forceLoad
		parentField.disableChangeEvents = true
		# set the selected value to tree picker input field
		seqDisplayText = parentWindow.generateSeqDisplayText record, displayField, displayValue
		parentField.setValue seqDisplayText

		parentField.sendValue = sendValue or displayValue

		# save these values
		parentField.lastDisplayValue = seqDisplayText
		parentField.lastSendValue = sendValue

		console.log 'saving last values: ', parentField, parentField.lastDisplayValue, parentField.lastSendValue
		# wait until isClickInside works right
		delayHide = Ext.Function.createDelayed ->
			parentWindow.hide()
			return
		, 1
		delayHide()
		console.log 'clicked on a tree item: ', displayValue, record, parentWindow

		# handle select event
		parentField.valueChanged = true
		rq = Corefw.util.Request
		url = rq.objsToUrl3(parentField.eventURLs['ONSELECT'])
		rq.sendRequest5 url, rq.processResponseObject, parentField.uipath, form.generatePostData()

	onTreePickerItemClick: (tree, record) ->
		return false if tree.up('coretreebase').isNodeDisabled(record)
		parentWindow = tree.up 'coretreepickerwindow'
		@onTreepickerClickOrSelect parentWindow, record
		return

	onTreePickerSelect: (rowModel, record, index, eOpts) ->
		parentWindow = rowModel.view.up('coretreepickerwindow')
		parentField = parentWindow.parentField
		if not parentField.isFirstEvent
			parentField.isFirstEvent = true
			if parentField.lastDisplayValue
				return
		@onTreepickerClickOrSelect parentWindow, record
		return

	onMonthPickerChange: (field, newValue, oldValue) ->
		return if field.suspendChangeEvents
		@fieldEvent 'ONCHANGE', field
		return
	monitorFieldChange: (field) ->
		fieldContainer = @getFieldContainer field
		if fieldContainer and fieldContainer.disableFormEvents
			return
		field.valueChanged = true
		return

	toogleComboBoxChangeEvent: (comp) ->
		comp.disableChangeEvent = not comp.disableChangeEvent
		return

	onClickLink: (field) ->
		evt = Corefw.util.Event
		@fieldEvent 'ONCLICK', field
		evt.enableUEvent field.uipath, 'ONCLICK'
		return

	onClickButtonIcon: (button) ->
		coreicon = button.up 'coreiconfield'
		@fieldEvent 'ONICONCLICK', coreicon
		return

	onClickLinkToDownload: (field) ->
		rq = Corefw.util.Request
		cm = Corefw.util.Common
		url = rq.objsToUrl3 field.eventURLs['ONDOWNLOAD']
		comp = field.up 'form'
		cm.download comp, url
		return

	onClickLinkToRedirect: (field) ->
		rq = Corefw.util.Request
		cm = Corefw.util.Common
		url = rq.objsToUrl3 field.eventURLs['ONREDIRECT']
		comp = field.up 'form'
		cm.redirect comp, url
		return

	onRadioGroupCheckChange: (radioGroup, newValue, oldValue) ->
		@onFieldCheckChange(radioGroup)
		return

	onCheckGroupCheckChange: (checkGroup) ->
		@onFieldCheckChange(checkGroup)
		return

	onTreeItemExpand: (node) ->
		treepanel = node.getOwnerTree()
		if node.data.leaf or node.childNodes.length or not treepanel.rendered
			return
		parent = treepanel.up()
		if parent.xtype is 'coretreefielddisplayvalue'
			parent = parent.up('coretreepickerwindow').parentField
		parent.expandingNodeId = node.data.id
		postData = if parent.generatePostData? then parent.generatePostData() else @getFieldContainer(parent).generatePostData()
		me = this
		appendTreeFragment = (respObj) ->
			for respNode in respObj
				model =
					id: respNode.index
					leaf: respNode.leaf
					checked: if treepanel.selectType isnt 'NONE' and treepanel.selectType then respNode.selected else undefined
					disabled: respNode.disabled
					matching: respNode.matching
					expanded: false
					origSelected: respNode.selected
				Ext.apply model, respNode.value
				node.appendChild model
			me.remarkParentNodeState node, respObj
			return

		rq = Corefw.util.Request
		field = treepanel.up('coretreefieldbase') or treepanel.up()
		eventURLs = field.eventURLs or field.cache?._myProperties.events or {}
		url = rq.objsToUrl3 eventURLs['ONTREEEXPAND']
		errMsg = 'Did not receive a valid response for the tree'
		method = 'POST'
		rq.sendRequest5 url, appendTreeFragment, parent.uipath, postData, errMsg, method
		return

	remarkParentNodeState: (currentNode, newChildrenNodes) ->
		selectedNodes = newChildrenNodes.filter (n) -> n.selected
		semiSelectedNodes = newChildrenNodes.filter (n) -> n.raw?.semiSelected
		isAllNodesSelected = selectedNodes.length is newChildrenNodes.length
		isAnyNodeSemiSelected = semiSelectedNodes.length > 0
		if isAnyNodeSemiSelected or (selectedNodes.length > 0 and not isAllNodesSelected)
			currentNode.selected = false
			currentNode.raw.semiSelected = true
			currentNode.set 'checked', true
		else if isAllNodesSelected
			currentNode.selected = true
			currentNode.raw.semiSelected = false
			currentNode.set 'checked', true
		parentNode = currentNode.parentNode
		if parentNode
			@remarkParentNodeState parentNode, parentNode.childNodes
		return

	simpleTreeItemClickHandler: (dataview, record, treenodeDom, index, e, isDblClick) ->
		coretree = dataview.up 'coretreesimple'
		scrollTop = dataview.el.dom.scrollTop
		callback = (respObj, ev, uipath, preProcess) ->
			ft = Corefw.util.Uipath.uipathToComponent uipath
			ft.tree.getView().el.dom.scrollTop = scrollTop
			# to fix a prod issue raised on Jul/16/2015
			# block tree item click event and here is the restore place
			# reuse previous code: a customized callback
			iv = Corefw.util.InternalVar
			iv.deleteByNameProperty uipath, 'treeItemClickEventsBlocked'
			console.log 'block removed'
			return
		if dataview.xtype is 'treeradioview'
			dataview.isCheckChanged = true
			dataview.onCheckChange record
		coretree.treeItemClickHandler record, treenodeDom, index, e, callback, isDblClick
		return

	simpleTreeItemLinkClickHandler: (dataview, record, treenodeDom, index, e, isDblClick) ->
		coretree = dataview.up 'coretreesimple'
		scrollTop = dataview.el.dom.scrollTop
		callback = (respObj, ev, uipath, preProcess) ->
			ft = Corefw.util.Uipath.uipathToComponent uipath
			ft.tree.getView().el.dom.scrollTop = scrollTop
			# to fix a prod issue raised on Jul/16/2015
			# block tree item click event and here is the restore place
			# reuse previous code: a customized callback
			iv = Corefw.util.InternalVar
			iv.deleteByNameProperty uipath, 'treeItemClickEventsBlocked'
			console.log 'block removed'
			return
		if dataview.xtype is 'treeradioview'
			dataview.isCheckChanged = true
			dataview.onCheckChange record
		coretree.treeItemLinkClickHandler record, treenodeDom, index, e, callback, isDblClick
		return

	onDBLClickSimpleTreeItem: (dataview, record, treenodeDom, index, e) ->
		@simpleTreeItemClickHandler dataview, record, treenodeDom, index, e, true
		return

	onClickSimpleTreeItem: (dataview, record, treenodeDom, index, e) ->
		@simpleTreeItemClickHandler dataview, record, treenodeDom, index, e, false
		return

	onClickSimpleTreeItemLink: (dataview, record, treenodeDom, index, e) ->
		@simpleTreeItemLinkClickHandler dataview, record, treenodeDom, index, e, false
		return

	onClickTreeMixedGridItem: (dataview, record, treenodeDom, index, e) ->
		console.log '**** onClickTreeMixedGridItem'
		e.stopEvent()
		return

	onClickTreeMixedGrid: (dataview, record, treenodeDom, index, e) ->
		coretree = dataview.up 'coretreemixedgrid'
		coretree.onClickTreeMixedGrid record, treenodeDom, index, e
		return

	onExpandOrCollapseMixedGrid: (node) ->
		treepanel = node.getOwnerTree()
		coretree = treepanel.up 'coretreemixedgrid'

		childNode = node.childNodes[0]
		node.removeChild childNode if childNode
		childNode = node.childNodes[0]
		if childNode
			Ext.removeNode Ext.DomQuery.selectNode '[data-recordid=' + childNode.internalId + ']', coretree.el.dom
			Ext.removeNode Ext.DomQuery.selectNode 'tr:not([data-recordid]) tr:not([data-recordid])', coretree.el.dom

		node.ignoreExpandEvent = false
		treenodeDom = Ext.DomQuery.selectNode '[data-recordid=' + node.internalId + ']', coretree.el.dom
		coretree.onTreeItemExpand node, node.internalId, treenodeDom
		return true

	comboBoxLookup: (field, isChange, newValue, oldValue) ->
		if field.xtype is 'coretreepicker' and (typeof oldValue is 'undefined' or newValue is oldValue or (not newValue or newValue.length < 1))
			return
		# to stop fire lookup event
		if field.isStop
			return
		rq = Corefw.util.Request

		# this function is called after the AJAX request returns from the server
		fieldComboCallback = (respObj = [], uipath) ->
			field.setComboValues respObj
			historyInfo = if field.cache then field.cache._myProperties.historyInfo else field.historyInfo
			historyValues = historyInfo?.historyValues
			field.addHistoryData historyValues, true
			field.expand()
			node = field.findRecordByValue field.getValue()
			if node
				field.picker.onItemSelect node
				field.picker?.focusNode(node)
			field.focus()
			return

		if not field.isNotFirstLookUp
			field.isNotFirstLookUp = true
			inputValue = ''
		else
			inputValue = field.getRawValue()

		val = if inputValue is undefined or inputValue is null then '' else inputValue
		url = rq.objsToUrl3 field.eventURLs['ONLOOKUP'], null, val
		errMsg = 'Did not receive a valid response for the combobox'
		method = 'POST'
		rq.sendRequest5 url, fieldComboCallback, field.uipath, null, errMsg, method

		return

	onIsLookupComboBoxChange: (field, newValue, oldValue) ->
		fieldContainer = @getFieldContainer(field)
		if fieldContainer.disableFormEvents or field.disableChangeEvent
			return
		@comboBoxLookup field, true, newValue, oldValue
		return

	onIsLookupComboBoxFocus: (field) ->
		lookupCacheable = field.cache?._myProperties?.lookupCacheable
		if lookupCacheable
			field.isNotFirstLookUp = true
			field.expand()
			return
		field.isNotFirstLookUp = false
		@comboBoxLookup field
		return

	onComboBoxSelect: (field) ->
		evt = Corefw.util.Event
		uipath = field.uipath
		evt.enableUEvent uipath, 'ONSELECT'
		@fieldEvent 'ONSELECT', field
		return

	onComboBoxDblClick: (field) ->
		evt = Corefw.util.Event
		uipath = field.uipath
		evt.enableUEvent uipath, 'ONDOUBLECLICK'
		@fieldEvent 'ONDOUBLECLICK', field
		return

	onFieldBlur: (field) ->
		# disable event if fieldContainer ONLOAD is taking place
		evt = Corefw.util.Event
		fieldContainer = @getFieldContainer(field)
		if fieldContainer.disableFormEvents
			return

		@clearCursorPosition field
		@removeFieldFocus field
		@fieldEvent 'ONBLUR', field
		evt.enableUEvent field.uipath, 'ONBLUR'
		return

	onFieldChange: (field) ->
		# disable event if fieldContainer ONLOAD is taking place
		evt = Corefw.util.Event
		fieldContainer = @getFieldContainer(field)
		if fieldContainer.disableFormEvents
			return
		evt.enableUEvent field.uipath, 'ONCHANGE'

		@saveCursorPosition field
		@saveFieldFocus field
		@fieldEventFireTask.delay 500, null, null, ['ONCHANGE', field]
		return

	onFieldCheckChange: (field) ->
		evt = Corefw.util.Event
		fieldContainer = @getFieldContainer(field)
		if fieldContainer.disableFormEvents
			return
		evt.enableUEvent field.uipath, 'ONCHANGE'
		field.valueChanged = true
		@fieldEvent 'ONCHANGE', field
		return

	onFieldFocus: (field) ->
		# don't process focus events from combobox fields
		if field?.xtype is 'combobox'
			return

		# disable event if fieldContainer ONLOAD is taking place
		fieldContainer = @getFieldContainer(field)
		if fieldContainer.disableFormEvents
			return

		@saveCursorPosition field
		@saveFieldFocus field
		@fieldEvent 'ONFOCUS', field
		return



	onClickIframe: (comp, data) ->
		rq = Corefw.util.Request
		uipath = comp.uipath
		url = rq.objsToUrl3 comp.eventURLs['ONCLICK'], ''
		for arg of data
			temp = arg + '=' + data[arg]
			url += '&' + temp

		postData = comp.up('form').generatePostData()
		rq.sendRequest5 url, rq.processResponseObject, uipath, postData, undefined, undefined, undefined, undefined
		return

	onFileFieldChange: (field, value, eOpts) ->
		fileHolder = field.up()
		prop = fileHolder.cache?._myProperties
		files = field.fileInputEl.dom.files
		disabledButton = (fieldField, disable) ->
			fileHolder = field.up()
			uip = Corefw.util.Uipath
			prop = fileHolder.cache?._myProperties
			parentCache = uip.uipathToParentCacheItem(prop.uipath)
			parentprop = parentCache?._myProperties

			for nav in parentprop.navs?._ar
				button = uip.uipathToComponent nav?.uipath
				button.setDisabled disable
			return

		if files and files.length > 0
			if field.validator() is true
				disabledButton field, false
				fileHolder.isStopUpload = false
			else
				disabledButton field, true
				fileHolder.isStopUpload = true

		return



	removeFieldFocus: (field) ->
		iv = Corefw.util.InternalVar
		fieldContainer = @getFieldContainer(field)
		uipath = fieldContainer.uipath
		formFocusFieldUipath = iv.getByUipathProperty uipath, 'formfieldfocus'
		if uipath is formFocusFieldUipath
			iv.deleteUipathProperty uipath, 'formfieldfocus'
		return


	saveFieldFocus: (field) ->
		iv = Corefw.util.InternalVar
		fieldContainer = @getFieldContainer(field)
		iv.setByUipathProperty fieldContainer.uipath, 'formfieldfocus', field.uipath
		return


	saveCursorPosition: (field) ->
		iv = Corefw.util.InternalVar

		# these field types don't have a cursor position
		if field.xtype in [
			'checkbox'
			'checkboxfield'
			'combobox'
			'combo'
		]
			return

		dom = field.getEl().dom
		node = Ext.dom.Query.selectNode 'input', dom
		if not node
			node = Ext.dom.Query.selectNode 'textarea', dom
			if not node
				return

		# chrome

		#Catching error when checkbox is selected. checkbox won't have selectionStart
		try
			cursPos = node.selectionStart

			console.log 'saving cursor position: ', cursPos
			iv.setByUipathProperty field.uipath, 'fieldcursorposition', cursPos
		catch
			console.log 'Exception occured while selectionStart is invoked on node ', node
		return


	clearCursorPosition: (field) ->
		iv = Corefw.util.InternalVar
		iv.deleteUipathProperty field.uipath, 'fieldcursorposition'
		return

	recordFieldFocusStatus: (field) ->
		if field.xtype is 'radiofield'
			iv = Corefw.util.InternalVar
			iv.setByNameProperty 'specialField', 'radio', field.inputValue
			radioGroup = field.up 'radiogroup'
			@saveFieldFocus radioGroup
		else
			if field.xtype is 'coretreepickernew' or field.xtype is 'coregridpicker'
				return
			@saveFieldFocus field
			@saveCursorPosition field
		return


	fieldEvent: (eventName, field) ->
		editor = field.up 'roweditor'
		return if editor # prevent to handle event fired from row editor
		rq = Corefw.util.Request
		evt = Corefw.util.Event
		#iv = Corefw.util.InternalVar
		uip = Corefw.util.Uipath
		uipath = field.uipath

		# see if an event of this type is already in progress
		# if so, don't fire it
		eventEnabledFlag = evt.getEnableUEventFlag uipath, eventName
		if not eventEnabledFlag
			return

		evt.disableUEvent uipath, eventName

		field.valueChanged = true
		if eventName is 'ONLOAD'
			postData = null
		else
			if field.xtype is 'coretreefieldbase' and field.xtype isnt 'coretreepickernew'
				postData = field.generatePostData()
			else
				container = @getFieldContainer(field)
				return if not container
				if container.xtype is 'coretoolbar' or container.xtype is 'corecomplextoolbar'
					toolbarContainer = uip.uipathToParentComponent container.uipath
					postData = toolbarContainer.generatePostData()
				else
					postData = container.generatePostData()


		# save the view's scroll position under this breadcrumb
		viewComp = field.up '[coretype=view]'
		if viewComp and viewComp.saveScrollPosition
			viewComp.saveScrollPosition()

		url = rq.objsToUrl3 field.eventURLs[eventName], field.localUrl
		rq.sendRequest5 url, rq.processResponseObject, uipath, postData
		return


	onFieldRenderEvent: (component) ->
		evt = Corefw.util.Event
		if component.fieldONLOADevent or component.fieldONREFRESHevent
			evt.fireRenderEvent component
		return



	getFieldContainer: (field) ->
		return field.up('fieldset') or field.up('form') or field.up('coretoolbar')

	validateChanging: (comp, opts) ->
		return if comp.isInlineFilter
		{minLength, maxLength, enforceMaxLength, errorMessage, shouldValidate} = @getMinAndMaxInfo comp
		return if not shouldValidate
		comp.inputEl.on 'keydown', (e, dom) ->
			if  e.keyCode isnt e.BACKSPACE
				value = comp.getValue() or ''
				# if value is a number value , make it as a string to count length
				if 'number' is typeof value
					value = value + ''
				if (maxLength - 1) < value.length
					e.preventDefault() if enforceMaxLength
			return
		comp.inputEl.on 'keyup', (e, dom) ->
			value = comp.getValue() or ''
			isValid = true
			if minLength > 0 and value.length < minLength
				isValid = false
			if maxLength > 0 and maxLength < value.length
				isValid = false
			comp.markInvalid errorMessage if isValid is false
			return
		return

# get min length , max length,enforceMaxLength from field or header
	getMinAndMaxInfo: (comp) ->
		info =
			shouldValidate: false
		if not comp.up('roweditor') # field in other container,such as form
			validations = comp?.cache?._myProperties?.validations or []
		else # field in row editor, get information from header cache
			parent = comp.up 'fieldcontainer'
			pathString = comp.name
			parent = parent?.cache?._myProperties
			headers = parent.allContents
			for header in headers
				break if header.pathString is pathString
			validations = if header? then header.validations else []

		constraintName = 'FieldLength'

		for constraint in validations
			break if constraint.constraintName is constraintName

		if constraint and constraint.constraintMap
			constraintMap = constraint.constraintMap
			info.minLength = constraintMap.minLength
			info.maxLength = constraintMap.maxLength
			info.enforceMaxLength = constraintMap.enforceMaxLength
			info.errorMessage = constraint.constraintMessage
			info.shouldValidate = info.minLength or info.maxLength

		return info