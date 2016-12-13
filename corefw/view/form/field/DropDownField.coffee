Ext.define 'Corefw.view.form.field.DropDownField',
	extend: 'Ext.form.field.ComboBox'
	mixins: ['Corefw.mixin.CoreField']
	xtype: 'coredropdownfield'
	queryMode: 'local'
	editable: false
	forceSelection: true
	displayField: 'displayValue'
	valueField: 'value'
	enableKeyEvents: false
# for caching query string from event key
	queryCache: []

	listConfig:
		style:
			whiteSpace: 'nowrap'

	initComponent: ()->
		fieldProps = @cache._myProperties
		@applyConfig fieldProps
		@configureTriggers()
		@applyStore fieldProps
		@callParent arguments

	applyConfig: (fieldProps)->
		config =
			name: fieldProps.name
			emptyText: fieldProps.emptyText
			multiSelect: fieldProps.multiSelect
			autoSelect: not fieldProps.multiSelect
			uipath: fieldProps.uipath
			value: fieldProps.value
			fieldLabel: fieldProps.title
			readOnly: fieldProps.readOnly
			disabled: fieldProps.disabled
			historyInfo: fieldProps.historyInfo
			hideTrigger: fieldProps.readOnly
			listeners: {}
		#	dropdown is not editable, the below are some behaviors only in dropdown:
		#	1. enable autocomplete	when dropdown is not editable
		#	2. set theme
		if not @editable
			# Adding font awesome icon for combobox
			su = Corefw.util.Startup
			if su.getThemeVersion() is 2
				config.triggerBaseCls = 'formtriggericon'
				config.triggerCls = 'combotrig'
				config.height = 26
				#removing combobox border right width for new theme
				config.fieldStyle =
					borderRightWidth: '0px'
			config.listeners.keydown = @onKeyDownEvent
			config.listeners.change = @onChangeEvent
		Ext.merge @, config

	applyStore: (fieldProps)->
		validValues = fieldProps.validValues
		if !validValues.length and fieldProps.hasOwnProperty 'displayValue'
			validValues = validValues.concat {displayValue: fieldProps.displayValue, value: fieldProps.value}
		st = @createStore fieldProps.uipath, validValues
		st and @store = st

# TODO: will be removed in Ext 5
	afterRender: ->
		@callParent arguments
		@triggerEl.elements[1]?.hide()

	onKeyDownEvent: (_, e)->
		return if e.keyCode < 31
		@queryCache.push String.fromCharCode e.keyCode
		q = @queryCache.join ''
		if @triggerAction is 'all'
			@doQuery q, true
		else if @triggerAction is 'last'
			@doQuery q, true
		else
			@doQuery q, false, true
		return

	onTriggerClick: ->
		@callParent arguments
		@queryCache = []

	onClearClick: ->
		return if @readOnly or @disabled
		@clearValue()
		@triggerEl.elements[1].hide()
		@updateLayout()
		@fireEvent 'clear', @
		@queryCache = []

# make field as clearable
	configureTriggers: ->
		version = Ext.getVersion().major
		baseCSSPrefix = Ext.baseCSSPrefix
		if version is 4
			@trigger1Cls = baseCSSPrefix + 'form-arrow-trigger'
			@onTrigger1Click = -> @onTriggerClick()
			@trigger2Cls = baseCSSPrefix + 'form-clear-trigger'
			@onTrigger2Click = @onClearClick
		else if version > 4
			@triggers =
				clear:
					weight: 1
					cls: Ext.baseCSSPrefix + 'form-clear-trigger'
					hidden: true
					handler: 'onClearClick'
					scope: 'this'
				picker:
					weight: 2
					handler: 'onTriggerClick'
					scope: 'this'

	createStore: (id, data = [])->
		return null if data.length is 0
		dropDown = @
		storeConfig =
			fields: [dropDown.displayField, dropDown.valueField]
			data: data
			id: id
		Ext.create 'Ext.data.Store', storeConfig

# hide/show clear trigger for Ext 4
	onChangeEvent: ->
		clearTrigger = @triggerEl.elements[1]
		if Ext.isEmpty @value
			clearTrigger.hide()
		else
			clearTrigger.show()
		return

# hide/show clear trigger for Ext 5
	updateValue: ->
		selectedRecords = @valueCollection.getRange();
		@callParent();
		if selectedRecords.length > 0
			@getTrigger('clear').show()
			@updateLayout()
		return

#override: to support setting object/array/string value
	setValue: (value)->
		if not Ext.isEmpty value
			me = @
			if not me.isRecord value
				if not Ext.isArray value
					arguments[0] = me.parseValue value
				else
					arguments[0] = value.map (v)->
						if me.isRecord v
							return v
						else
							return me.parseValue v
		@callParent arguments

	isRecord: (v)->
		v.hasOwnProperty 'store'

	parseValue: (v)->
		if Ext.isObject v
			return v[@valueField] or v.value
		else
			return v

	bindStore: (store)->
		@callParent arguments
		if store
			historyValues = @historyInfo?.historyValues
			@addHistoryData historyValues, true
		return

	bindData: (dropdownValues) ->
		dropdownValues = Ext.Array.from dropdownValues
		return false if dropdownValues.length is 0
		@getStore().loadData Ext.Array.from dropdownValues
		return true

	addHistoryData: (data, isRemoveRepeat)->
		datas = Ext.Array.from data
		if not datas.length
			return false
		dropdown = @
		store = dropdown.getStore()
		valueField = dropdown.valueField
		if isRemoveRepeat
			store.each (record)->
				if record.raw.isHistory
					storeVal = record.get valueField
					for d,i in datas
						if storeVal is d[valueField]
							store.removeAt i
							return
				return

		datas.forEach (d)-> d.isHistory = true
		store.loadData datas, true
		return true

# decode the display value
	getDisplayValue: ->
		displayValue = @callParent arguments
		# decode the value for displaying
		Ext.htmlDecode displayValue

	generatePostData: ->
		value = @getValue()
		displayValue = @getRawValue()
		name: @name
		value: if Ext.isEmpty(value) then "" else value
		displayValue: if Ext.isEmpty(displayValue) then "" else displayValue