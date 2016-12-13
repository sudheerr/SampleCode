# contains functions common to all field containers(Fieldset/FormElement)
Ext.define 'Corefw.mixin.FieldContainer',
	constructor: ->
		@initializeConstants()
		return

	# initialize constants used in other parts of the class
	# should be deleted after use to keep it from cluttering up the class
	initializeConstants: ->
		cm = Corefw.util.Common
		rdr = Corefw.util.Render
		su = Corefw.util.Startup

		@xtypeConfigDef =
			'Default':
				xtype: 'citirisktextinput'
			textfield:
				xtype: 'citirisktextinput'
			number:
				xtype: 'corenumberfield'
			combobox:
				xtype: 'comboboxfield'
			trigger:
				xtype: 'coretriggerfield'
			advanced_combobox:
				xtype: 'advancedcomboboxfield'
			textarea:
				xtype: 'coretextarea'
			radiogroup:
				xtype: 'coreradiogroup'
			switchbutton:
				xtype: 'coreSwitchBtn'
			'date':
				xtype: 'coredatefield'
				format: 'd M Y'
			datestring:
				xtype: 'coredatestringfield'
				format: 'd M Y'
			month_picker:
				xtype: 'coremonthpicker'
				format: 'Y-m'
			togglebutton:
				xtype: 'coretoggleslidefield'
			richtext:
				xtype: 'corehtmleditor'
			checkbox:
				xtype: 'checkbox'
			checkgroup:
				xtype: 'corecheckboxgroup'
			icon:
				xtype: 'coreiconfield'
			objectgrid:
				xtype: 'coreobjectgrid'
			object_grid:
				xtype: 'coreobjectgrid'
			rcgrid:
				xtype: 'corercgrid'
			simpletree:
				xtype: 'coretreesimple'
			tree:
				xtype: 'coretreesimple'
			tree_grid:
				xtype: 'coretreegrid'
			tree_navigation:
				xtype: 'coretreeleftnavigation'
			treenavigation:
				xtype: 'coretreeleftnavigation'
			mixedgrid:
				xtype: 'coretreemixedgrid'
			mixed_grid:
				xtype: 'coretreemixedgrid'
			hierarchy_object_grid:
				xtype: 'corehierarchygrid'
			chart:
				xtype: 'corechartfield'
			cell_grid:
				xtype: 'coreallocgrid'
			grouped_grid:
				xtype: 'coregroupedtreegrid'
			cellgrid:
				xtype: 'coreallocgrid'
			label:
				xtype: 'displayfield'
				fieldStyle:
					'white-space': 'nowrap'
					'overflow': 'hidden'
					'text-overflow': 'ellipsis'

			link:
				xtype: 'corelinkfield'
				labelStyle: 'padding-bottom: 6px' if su.getThemeVersion() is 2
				fieldStyle:
					'margin-top': '0px' if su.getThemeVersion() is 2

			file_upload:
				xtype: 'corefileupload'
			remoteurl:
				xtype: 'coreiframefield'
				element: this
			remote_url:
				xtype: 'coreiframefield'
				element: this
			tree_picker:
				xtype: 'coretreepickernew'
			grid_picker:
				xtype: 'coregridpicker'
			fieldset:
				xtype: 'corefieldset'
			pivotgrid:
				xtype: 'pivottablefield'
			dual_listbox:
				xtype: 'coreduallistbox'

		@fieldObjDef =
			xtype: 'displayfield'
			labelAlign: 'top'
			msgTarget: if su.getThemeVersion() is 2 then 'under' else 'side'
			labelStyle: 'padding-bottom: 6px' if su.getThemeVersion() is 2

	deleteConstants: ->
		delete @xtypeConfigDef
		delete @fieldObjDef
		return

	# starting point for form layout
	layoutMain: ->
		me = this
		layoutManager = me.layoutManager
		if not layoutManager.validate()
			me.addCls 'invalid-layout'
			return
		layoutManager.setLayoutVariables? me
		me.initializeConstants()

		cache = me.cache
		props = cache._myProperties
		fields = me.getFormCacheFields()

		fieldDefs = []
		me.contentDefs = fieldDefs
		for field in fields
			fieldProps = field?._myProperties
			if not fieldProps?.isRemovedFromUI and fieldProps?.visible
				verSepExists = false
				if props.verticalSeparator
					verSepExists = props.verticalSeparator.length
				fieldDef = me.genFieldDef field, verSepExists
				fieldDefs.push fieldDef if fieldDef

		layoutManager.initLayout()
		Corefw.util.Render.renderNavs props, me
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			me.initCorrectMessage()
			me.addErrorMessageTips()

		me.renderMessages()
		me.renderFieldMessages()
		me.deleteConstants()
		me.verticalSep()
		Corefw.util.Data.displayFormData this, cache
		return

	initCorrectMessage: ->
		me = this
		fields = me.query 'field'
		validtnXtypes = ['citirisktextinput', 'textareafield', 'corenumberfield', 'comboboxfield', 'citiriskdatepicker',
						 'coretreepickernew', 'coredatefield', 'coredatestringfield']
		for field in fields
			if field.xtype in validtnXtypes
				props = field.cache?._myProperties
				if props?.validations.length > 0
					validations = props.validations
					correctMsg = ''
					@setCorrectMessage field, correctMsg
		return

	setCorrectMessage: (field, correctMsg) ->
		generateCorrectMessage = (field) ->
			Ext.create 'Corefw.view.form.field.CorrectMessage',
				field: field
				renderTo: field.bodyEl
				correctMsg: correctMsg
			return
		if field.rendered
			generateCorrectMessage field
		else
			field.on and field.on 'afterrender', (field) ->
				generateCorrectMessage field
				return
		return

	addErrorMessageTips: ->
		me = this
		fields = me.query 'field'
		for field in fields
			generateErrorMessageTips = (field) ->
				field.on 'errorchange', (field) ->
					errorTip = ''
					if field.activeErrors?.length > 0 and field.errorEl
						for error in field.activeErrors
							errorTip += error
						field.errorEl.set 'data-qtip': errorTip
					return
				return
			if field.rendered
				generateErrorMessageTips field
			else
				field.on and field.on 'afterrender', (field) ->
					generateErrorMessageTips field
					return
		return

# Below function adds the vertical separator using absolute layout for the form.
	verticalSep: ->
		su = Corefw.util.Startup
		# look for the vertical separator property in props
		me = this
		lv = me.lv
		props = me.cache._myProperties
		verticalSepAr = props?.verticalSeparator

		if not (verticalSepAr and verticalSepAr.length)
			return
		SepAr = []

		for verticalSep in verticalSepAr

			verticalSepArCoord =
				x: verticalSep #-0.025 # (math is done to place vertical separator with some space after the column instead of placing it very next to the coumn)
				y: 0
				xsize: 0
				ysize: 0
			th = lv.numRows * lv.panelRowHeight - 20 + 'px'
			margin = "#{(lv.extraMarginTop or 0) + 20}px 0px 0px"
			if su.getThemeVersion() is 2
				margin = margin + ' -15px'
			else
				margin = margin + ' -6px'
			verticalSepArobj =
				xtype: 'component'
				width: '1px'
				height: th
				orig: verticalSepArCoord
				style:
					borderColor: '#BFBFBF'
					margin: margin
					borderWidth: '0px 1px 0px 0px'
				#borderRadius: '1px'
					borderStyle: 'solid'

			SepAr.push verticalSepArobj

			@add SepAr
		return


	updateUIData: (cache) ->
		cm = Corefw.util.Common
		iv = Corefw.util.InternalVar
		props = cache._myProperties
		cm.updateCommon this, props
		@cache = cache
		return if not @rendered
		@layoutManager.removeAll()
		#ExtJS own issue, delete its _boundItems|wasValid to bind dynamic formBind field
		relativeForm = @form
		if relativeForm
			delete relativeForm.wasValid
			delete relativeForm._boundItems
		@initializeConstants()
		@disableFormEvents = true
		@layoutMain()
		@elementMixinRender?()
		@deleteConstants()
		@disableFormEvents = false
		Corefw.util.Render.appendPendingLayout this
		return

	updateField: (field, cache) ->
		oldCache = field.cache
		me = this
		me.disableFormEvents = true
		field.cache = cache
		props = cache._myProperties
		if props.isRemovedFromUI
			parent = field.up()
			parent.remove field
			return
		# update the properties
		disabled = not props.enabled
		disabled isnt field.disabled and field.setDisabled disabled
		hidden = not props.visible
		hidden isnt field.hidden and field.setVisible props.visible
		readOnly = props.readOnly
		readOnly isnt field.readOnly and field.setReadOnly? readOnly
		# update the value
		if props.type is 'COMBOBOX' and props.validValues?.length > 0
			field.setComboValues props.validValues
		if field.updateByCache
			field.updateByCache cache
		else if props.type in ['RADIOGROUP', 'CHECKGROUP']
			value = {}
			value[props.name] = props.value
			field.setValue value
		else
			value = props.value
			field.setValue value
		me.disableFormEvents = false
		# update the error/warning messages
		field.unsetActiveError()
		field.unsetActiveWarning()
		messages = props.messages
		if error = messages.ERROR
			field.setActiveError error
			field.doComponentLayout()
		else if warning = messages.WARNING
			field.setActiveWarning warning
		# update the css class
		oldClsListStr = oldCache._myProperties.cssClass
		oldClsList = oldCache._myProperties.cssClassList
		if oldClsList.length > 0
			oldClsListStr = oldClsList.join ' '
		newClsListStr = props.cssClass
		newClsList = props.cssClassList
		if newClsList.length > 0
			newClsListStr = newClsList.join ' '
		if oldClsListStr isnt newClsListStr
			oldClsList.forEach (oldCls) ->
				field.removeCls oldCls
			field.addCls newClsListStr
		return

	shouldUpdateField: (comp, cache) ->
		res = true
		props = cache._myProperties
		{widgetType, type} = props
		excludedTypes = ['advanced_combobox', 'grid_picker', 'tree_picker']
		isExcludedType = if excludedTypes.includes then excludedTypes.includes(type) else excludedTypes.indexOf(type) > -1
		return (comp.setValue or comp.updateByCache) and not isExcludedType

	replaceChild: (cache, ev) ->
		uip = Corefw.util.Uipath
		me = this
		layoutManager = me.layoutManager
		props = cache._myProperties
		uipath = props.uipath
		comp = uip.uipathToComponent uipath
		if not comp
			return
		if props.widgetType is 'FIELD'
			if me.shouldUpdateField comp, cache
				me.updateField comp, cache
			return
		componentIndex = layoutManager.getContentIndex comp
		# special case for updating grid here, will be removed in new version
		if comp.grid
			Ext.suspendLayouts()
			shouldReCreateGrid = comp.grid.shouldReCreateGrid cache

			if comp.grid?.isEditing is true
				comp.cache = cache
				grid = comp.grid
				grid.updateFromCache cache
				Ext.resumeLayouts(true)
				return
			else if not shouldReCreateGrid
				comp.cache = cache
				grid = comp.grid
				restoreScroll = grid.cacheScrollValue()
				Ext.resumeLayouts(true)
				grid.updateStoreFromCache cache
				restoreScroll()
				return

			layoutManager.remove comp
		else
			layoutManager.remove comp

		if me.el
			me.initializeConstants()
			verSepExists = props.verticalSeparator
			fieldDef = me.genFieldDef cache, verSepExists
			me.deleteConstants()
			layoutManager.add fieldDef, componentIndex
			if not (comp.grid or comp.tree)
				me.disableFormEvents = true
				Corefw.util.Data.updateDisplayFormData me, cache
				me.disableFormEvents = false
		if comp and comp.grid
			Ext.resumeLayouts true
		Corefw.util.Render.appendPendingLayout this
		return

	genFieldDef: (field, verSepExists) ->
		cm = Corefw.util.Common
		evt = Corefw.util.Event
		su = Corefw.util.Startup
		iv = Corefw.util.InternalVar
		fieldProps = field._myProperties
		newObj = cm.objectClone @fieldObjDef
		fieldType = fieldProps.type?.toLowerCase()
		if not fieldType
			fieldType = fieldProps.widgetType?.toLowerCase()
			if not fieldType
				console.log 'ERROR: genFieldDef: field type not found ', fieldType, fieldProps
				return

		fieldType = fieldType.toLowerCase()
		xtypeObj = @xtypeConfigDef[fieldType]

		if fieldProps.format
			xtypeObj.format = fieldProps.format

		if xtypeObj and typeof xtypeObj is 'object'
			Ext.apply newObj, xtypeObj
		else
			console.log 'ERROR: genFieldDef: field type not found: type, props: ', fieldType, fieldProps
			return

		addlConfig =
			cache: field
			name: fieldProps.name
			labelSeparator: ''
			disabled: not fieldProps.enabled
			hidden: not fieldProps.visible

		if fieldProps.width
			addlConfig.width = fieldProps.width

		if fieldProps.readOnlyStyle is true
			if su.getThemeVersion() is 2
				newObj.baseBodyCls = 'fieldReadOnlyCls'
			else
				newObj.fieldStyle =
					backgroundColor: '#D5D6D7'
					backgroundImage: 'none'
					borderColor: '#a2a2a2 '
					opacity: 0.98
				newObj.labelStyle =
					'opacity:1'

		# Adding border color for field hover
		if su.getThemeVersion() is 2
			newObj.overCls = 'fieldOverCls'
		Ext.apply newObj, addlConfig

		cssClassList = fieldProps.cssClassList
		if not fieldProps.cssClass and iv.getByUipathProperty(fieldProps.uipath, 'mixed-form-element') is true
			cssClassList.push 'mixed-form-element'
		if cssClassList?.length
			newObj.cls = cssClassList.join ' '
		else
			cssClass = fieldProps.cssClass
			if cssClass
				newObj.cls = cssClass

		@setFieldLabel newObj, fieldProps

		#Apply fieldstyle
		if fieldProps.style
			newObj.fieldStyle = @getFieldStyle fieldProps

		uipath = fieldProps.uipath
		newObj.uipath = uipath
		newObj.setActiveWarning = @setFieldWarningMessage
		newObj.unsetActiveWarning = @unsetFieldWarningMessage

		addlSetup = @addlComponentSetup[fieldType]
		if addlSetup
			addlSetup.call this, newObj, fieldProps

		if verSepExists
			newObj.style =
				backgroundColor: '#ffffff'
				zIndex: 1
		evt.addEvents fieldProps, 'field', newObj

		@configureValidation fieldProps, newObj

		if fieldProps.fieldMask
			newObj.inputMask = fieldProps.fieldMask
			newObj.enableKeyEvents = true

		# re-enable all field events

		evt.enableUEvent uipath, 'ONSELECT'
		evt.enableUEvent uipath, 'ONCHANGE'
		evt.enableUEvent uipath, 'ONBLUR'

		return newObj

	setFieldWarningMessage: (warningMessage) ->
		field = this

		genWarningMessage = (field) ->
			inputRow = field.inputRow
			if not inputRow
				return
			field.activeWarning = Ext.create 'Corefw.view.form.field.WarningMessage',
				field: field,
				renderTo: inputRow,
				message: warningMessage
			return

		if field.rendered
			genWarningMessage field
		else
			field.on and field.on 'afterrender', (field) ->
				genWarningMessage field
				return

		return
	unsetFieldWarningMessage: ->
		field = this
		if field.activeWarning
			field.activeWarning.destroy()
			field.inputEl.dom.classList.remove 'x-form-warning-field'
			field.inputRow.dom.querySelector('.x-component-field-warningmessage')?.remove?()
			delete field.activeWarning
		return
	setFieldLabel: (newObj, fieldProps) ->
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			if newObj.xtype is 'corechartfield'
				return

		if fieldProps.title
			newObj.fieldLabel = fieldProps.title
		else
			if su.getThemeVersion() is 2
				if newObj.xtype isnt 'textareafield'
					newObj.fieldLabel = '&nbsp;'
			else
				newObj.fieldLabel = '&nbsp;'
		return

	getFormCacheFields: ->
		formCache = @cache
		fields = []

		# add all the fields to the fields array
		for key, field of formCache
			if key isnt '_myProperties'
				fields.push field

		return fields

	renderTooltips: (fieldDefs) ->
		me = this
		needDelayTooltips = Corefw.util.Startup.getStartupObj().delayTooltips is true
		formItemCls = Ext.form.Labelable::formItemCls
		tooltipConfig =
			dismissDelay: 0
			target: me.el
			delegate: ":any(.#{formItemCls}|.cv-form-abs-btn)"
			renderTo: Ext.getBody()
			listeners:
				beforeshow: (tip) ->
					triggerElement = tip.triggerElement
					# contentComp is a filed/absolute nav
					contentComp = Ext.getCmp tip.triggerElement.id
					if not contentComp
						return false
					tooltip = contentComp.cache?._myProperties?.toolTip
					if not tooltip
						compXtype = contentComp.xtype
						switch compXtype
						# a nav
							when 'button'
								labelDom = contentComp.btnInnerEl?.dom
						# a swithBtn
							when 'coreSwitchBtn'
								labelDom = contentComp.header?.titleCmp?.textEl?.dom
							when 'coretriggerfield'
								labelDom = contentComp.inputEl?.dom
								if labelDom and labelDom.scrollWidth > labelDom.clientWidth
									tip.update labelDom.value
									tip.maxWidth = 600
									return
								return false
							else
							# a field
								labelDom = contentComp.labelEl?.dom
						if labelDom and labelDom.scrollWidth > labelDom.clientWidth
							tip.update labelDom.textContent

							return
						return false

					visibleTooltips = Ext.ComponentQuery.query 'tooltip[hidden=false]'
					# a field is a grid, a grid has its tooltip, and its cells have tooltips as well
					# when mouse over on its cell, tooltip on grid should not be seen
					if visibleTooltips.length > 0
						return false
					tip.update tooltip
					return
				click:
					element: 'el'
					fn: (el, d) ->
						Ext.getCmp(@id).showAt @getXY
						return
		tooltipConfig.hideDelay = 1200 if needDelayTooltips
		me.tooltipManager = Ext.create 'Ext.tip.ToolTip', tooltipConfig
		return

	#Display messages.error
	#	if messages.error
	#display messages.warn
	#	if !messages.error and messages.warn
	renderFieldMessages: ->
		me = this
		fieldDefs = me.contentDefs
		messagesToDisplay = []
		genFieldMessage = (fmessages) ->
			return if not fmessages
			messageStr = ''
			for fmessage in fmessages
				if fmessage
					messageStr += fmessage + '<br>'
			# Legacy code
			# a hack to get the entire tooltip to display
			if messageStr
				messageStr += '&nbsp;'
			return messageStr
		for fieldDef in fieldDefs
			props = fieldDef.cache?._myProperties
			uipath = props.uipath
			messages = props.messages
			if messages
				errorMessage = genFieldMessage messages.ERROR
				warningMessage = genFieldMessage messages.WARNING

				if errorMessage or warningMessage
					message =
						uipath: uipath
						error: errorMessage
						warning: warningMessage

					messagesToDisplay.push message


		errorDisplayFunc = ->
			console.log 'messagesToDisplay: messagesToDisplay: ', messagesToDisplay, this
			if not messagesToDisplay
				console.log 'messagesToDisplay not found'
				return
			else
				console.log 'messagesToDisplay found': messagesToDisplay
			for message in messagesToDisplay
				uipath = message.uipath
				comp = me.down "[uipath=#{uipath}]"
				if not comp
					return
				if message.error
					comp.setActiveError message.error
					su = Corefw.util.Startup
					if su.getThemeVersion() is 2
						comp.errorEl?.set 'data-qtip': message.error
				else
					comp.setActiveWarning message.warning if message.warning
				comp.doComponentLayout()
			return

		if messagesToDisplay.length
			# the delay amount doesn't matter,
			#    it just has to run after this function exits
			myFunc = Ext.Function.createDelayed errorDisplayFunc, 1
			myFunc()
		return

	renderMessages: ->
		me = this
		props = me.cache._myProperties
		messageObj = props.messages
		if not messageObj
			return

		statusMsgs = []
		typesOfMessages = ['ERROR', 'WARNING', 'SUCCESS', 'INFORMATION']

		for msgType in typesOfMessages
			msgArray = messageObj[msgType]
			if msgArray and msgArray.length
				for msg in msgArray
					newStatusMsg =
						level: msgType.toLowerCase()
						text: msg
					statusMsgs.push newStatusMsg

		if not statusMsgs.length
			return

		# just testing: render error/status object at the top of the form
		statusObj =
			xtype: 'statusview'
			statusMsgs: statusMsgs
			margin: '6 0 0 0'

		me.layoutManager.addStatus statusObj
		return

	# additional setup required for specific component types
	# newCompObj has not been added yet, will get added after function returns
	# uiObj is the original JSON item
	addlComponentSetup:
		textfield: (newCompObj, fieldProps) ->
			#newCompObj.checkChangeBuffer = 400
			if fieldProps.masked
				newCompObj.inputType = 'password'
			if fieldProps.emptyText
				newCompObj.emptyText = fieldProps.emptyText
			if    fieldProps.format
				if fieldProps.format.indexOf('#') > -1
					newCompObj.transformRawValue = (value) ->
						formarReg = /([#]+)([^#]+)?/g

						index = 0
						newValue = @format.replace(formarReg, (word, g1, g2) ->
							result = value.substring(index, index + g1.length)
							if g2
								result = result + g2
								index += g1.length
							return result
						)
						return newValue
			return
		citirisktextinput: (newCompObj, fieldProps) ->
			#newCompObj.checkChangeBuffer = 400
			if fieldProps.masked
				newCompObj.inputType = 'password'
			if fieldProps.emptyText
				newCompObj.emptyText = fieldProps.emptyText
			return
		number: (newCompObj, fieldProps) ->
			newCompObj.hideTrigger = false
			newCompObj.keyNavEnabled = false
			newCompObj.mouseWheelEnabled = false
			newCompObj.format = fieldProps.format
			newCompObj.checkChangeBuffer = 50
			spinnerSpec = fieldProps.spinnerSpec
			if spinnerSpec
				newCompObj.step = spinnerSpec.numberStep
				newCompObj.maxValue = spinnerSpec.upperBound
				newCompObj.minValue = spinnerSpec.lowerBound

			return
		treepicker: (newCompObj, fieldProps) ->
			@addlComponentSetup.combobox newCompObj, fieldProps

		chart: (newCompObj, fieldProps) ->
			su = Corefw.util.Startup
			if su.getThemeVersion() isnt 2
				newCompObj.fieldLabel = fieldProps.title
			return

		combobox: (newCompObj, fieldProps) ->
			su = Corefw.util.Startup
			if fieldProps.emptyText
				newCompObj.emptyText = fieldProps.emptyText

			# if "isLookup", hide the trigger, no store attached
			# write controller action to take this and do something with it
			addlConfig = {}
			config =
				displayField: 'dispField'
				valueField: 'val'
			comboClass = Corefw.view.form.field.ComboboxField
			if comboClass.isLookupable fieldProps
				lookupCls = 'citiriskLookup'
				addlConfig =
					isLookup: true
					hideTrigger: true
					cls: if newCompObj.cls then (newCompObj.cls + ' ' + lookupCls) else lookupCls
					minChars: 1
			else
				addlConfig =
					queryMode: 'local'
				# Adding font awesome icon for combobox
				if su.getThemeVersion() is 2
					addlConfig.triggerBaseCls = 'formtriggericon'
					addlConfig.triggerCls = 'combotrig'
					#addlConfig.height = 28
					#removing combobox border right width for new theme
					if fieldProps.readOnly isnt true
						newCompObj.fieldStyle =
							borderRightWidth: '0px'


			addlConfig.multiSelect = fieldProps.multiSelect
			addlConfig.autoSelect = not fieldProps.multiSelect
			addlConfig.editable = comboClass.isEditable fieldProps
			addlConfig.typeAhead = addlConfig.editable
			name = fieldProps.uipath
			validValues = fieldProps.validValues
			if not validValues.length
				if fieldProps.hasOwnProperty 'displayValue'
					validValues = validValues.concat {displayValue: fieldProps.displayValue, value: fieldProps.value}
				else
					validValues = validValues.concat fieldProps.value
			st = Corefw.util.Data.arrayToStore name, null, validValues, config
			if st
				config.store = st

			Ext.apply config, addlConfig
			Ext.apply newCompObj, config

			return

		advanced_combobox: (newCompObj, fieldProps) ->
			return @addlComponentSetup.combobox newCompObj, fieldProps

		radiogroup: (newCompObj, fieldProps) ->
			cm = Corefw.util.Common
			su = Corefw.util.Startup
			items = []
			addlConfig =
				defaultType: 'radiofield'
				items: items

			newCompObj.columns = fieldProps.columns
			newCompObj.vertical = fieldProps.vertical

			itemConfigDef =
				name: fieldProps.name

			if su.getThemeVersion() is 2
				itemConfigDef.checkedCls = 'radiogroupcls'

			groupValue = cm.getValue fieldProps.value
			if fieldProps.validValues
				for radioValue in fieldProps.validValues
					itemConfig = cm.objectClone itemConfigDef
					itemConfig.boxLabel = cm.getDisplayValue radioValue
					itemConfig.inputValue = cm.getValue radioValue
					itemConfig.checked = (itemConfig.inputValue is groupValue)
					if not Ext.Object.isEmpty(fieldProps.disabledValidValues) and Ext.Array.contains fieldProps.disabledValidValues, itemConfig.inputValue
						itemConfig.disabled = true
					else
						itemConfig.disabled = false

					items.push itemConfig

			Ext.apply newCompObj, addlConfig
			return

		switchbutton: (newCompObj, fieldProps) ->
			cm = Corefw.util.Common
			su = Corefw.util.Startup
			items = []
			addlConfig =
				layout: 'hbox'
				defaultType: 'button'
				items: items
			if su.getThemeVersion() isnt 2
				addlConfig.defaults =
					flex: 1

			itemConfigDef =
				name: fieldProps.name

			groupValue = cm.getValue fieldProps.value
			if fieldProps.validValues
				for radioValue in fieldProps.validValues
					itemConfig = cm.objectClone itemConfigDef
					itemConfig.text = cm.getDisplayValue radioValue
					itemConfig.inputValue = cm.getValue radioValue
					itemConfig.pressed = (itemConfig.inputValue is groupValue)

					items.push itemConfig

			Ext.apply newCompObj, addlConfig
			return

		checkgroup: (newCompObj, fieldProps) ->
			cm = Corefw.util.Common
			items = []
			su = Corefw.util.Startup
			newCompObj.items = items
			delete newCompObj.name
			newCompObj.columns = fieldProps.columns
			newCompObj.vertical = fieldProps.vertical

			itemConfigDef =
				name: fieldProps.name
				xtype: 'checkboxfield'

			if su.getThemeVersion() is 2
				itemConfigDef.checkedCls = 'checkboxfieldcls'

			groupValue = cm.getValue fieldProps.value
			if not Ext.isArray groupValue
				groupValue = [groupValue]
			if fieldProps.validValues
				for checkItem in fieldProps.validValues
					itemConfig = cm.objectClone itemConfigDef
					itemConfig.boxLabel = cm.getDisplayValue checkItem
					itemConfig.inputValue = cm.getValue checkItem
					itemConfig.checked = Ext.Array.contains groupValue, itemConfig.inputValue
					if not Ext.Object.isEmpty(fieldProps.disabledValidValues) and Ext.Array.contains fieldProps.disabledValidValues, itemConfig.inputValue
						itemConfig.disabled = true
					else
						itemConfig.disabled = false

					items.push itemConfig

			return
		checkbox: (newCompObj, fieldProps) ->
			su = Corefw.util.Startup
			if su.getThemeVersion() is 2
				newCompObj.checkedCls = 'checkboxcls'
			return

	configureValidation: (props, fieldObj) ->
		validations = props.validations
		if not validations
			validations = props.feValidations
			if not validations
				return

		validtnXtypes = ['citirisktextinput', 'textfield', 'textareafield', 'corenumberfield', 'combobox',
						 'comboboxfield', 'citiriskdatepicker', 'coretreepickernew', 'coredatefield',
						 'coredatestringfield']
		su = Corefw.util.Startup

		if validations and validations.length
			for validtn in validations
				name = validtn.constraintName
				message = validtn.constraintMessage
				if not name
					name = validtn.name
					message = validtn.message
				switch name
					when 'FieldNotNull'
						if fieldObj.xtype in validtnXtypes
							# the star is actually black
							redend = '&nbsp;*'
							if su.getThemeVersion() is 2
								fieldObj.fieldLabel = fieldObj.fieldLabel
								fieldObj.labelClsExtra = 'mandatoryLabel'
								redend = ''

							if not Ext.String.endsWith fieldObj.fieldLabel, redend
								fieldObj.fieldLabel = fieldObj.fieldLabel + redend

							fieldObj.allowBlank = false
							fieldObj.blankText = if message then message + '\n<br>' else 'Field can not be blank'
					when 'FieldRegex'
						if fieldObj.xtype in validtnXtypes
							pattern = validtn?.constraintMap?.pattern
							if not pattern
								continue
							fieldObj.regex = new RegExp pattern
							fieldObj.regexText = if message then message + '\n<br>' else 'Field failed validation'
		return


	getFieldStyle: (props) ->
		style = props.style
		getBgColor = (bg) ->
			colorMap =
				'HIGHLIGHT': '#f6efcc'
			bgcolor = colorMap[bg]
			if bgcolor then return bgcolor else return bg

		fieldStyle = ''

		if style.fontStyle isnt 'NORMAL'
			fieldStyle = "#{fieldStyle} font-style:#{style.fontStyle.toLowerCase()};"

		if    style.fontWeight isnt 'NORMAL'
			fieldStyle = "#{fieldStyle} font-weight:#{style.fontWeight.toLowerCase()};"

		if    style.textDecoration isnt 'NONE'
			temp = style.textDecoration.toLowerCase()
			if temp is 'linethrough'
				temp = 'line-through'
			fieldStyle = "#{fieldStyle} text-decoration:#{temp};"

		if    style.cursor isnt 'DEFAULT'
			fieldStyle = "#{fieldStyle} cursor:#{style.cursor.toLowerCase()};"

		if    style.bgcolor
			bgcolor = getBgColor style.bgcolor
			typeReg = /(combobox)|(checkbox)/i
			if typeReg.test props.type
				fieldStyle = "#{fieldStyle} background-color: #{bgcolor};"
			else
				fieldStyle = "#{fieldStyle} background-image:none; background-color: #{bgcolor};"
		fieldStyle = "#{fieldStyle} color:##{style.hexColor};"
		return fieldStyle;

	# given a form cache object, returns a postData object with the contents of the form, including the embedded data
	generatePostData: ->
		uip = Corefw.util.Uipath

		cache = @cache
		props = cache._myProperties

		fields = []
		postData =
			name: props.name
			allContents: fields

		# go through all fields one at a time, and add them
		for key, field of cache
			if key isnt '_myProperties'
				fieldObj = null
				fieldProps = field._myProperties

				uipath = fieldProps.uipath
				comp = uip.uipathToComponent uipath

				if not comp
					continue

				if comp.generatePostData
					fieldObj = comp.generatePostData()
				else
					val = comp.getValue and comp.getValue()
					if val is undefined
						continue

					fieldObj =
						name: key
						value: val

				if fieldObj
					fields.push fieldObj

		return postData

	inheritableStatics:
		createDataCache: (dataItem, cache) ->
			cache._myProperties.data = {}
			return