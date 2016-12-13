Ext.define 'Corefw.view.form.field.TriggerField',
	extend: 'Ext.form.field.Trigger'
	mixins: ['Corefw.mixin.CoreField']
	xtype: 'coretriggerfield'
	forceSelection: false
	componentCls: 'custom-trigger-field'
	editable: true
	initComponent: ->
		me = this
		me.forceSelection = true
		fieldProps = @cache._myProperties
		version = Corefw.util.Startup.getThemeVersion()
		if version is 2
			me.fieldStyle =
				borderRightWidth: '0'
		@applyConfig fieldProps
		# force selection as true when combo is not editable
		@configureTriggers()
		@callParent arguments
		return

	applyConfig: (fieldProps) ->
		config =
			name: fieldProps.name
			emptyText: fieldProps.emptyText
			uipath: fieldProps.uipath
			value: fieldProps.value
			readOnly: fieldProps.readOnly
			disabled: fieldProps.disabled
			historyInfo: fieldProps.historyInfo
			hideTrigger: fieldProps.readOnly
			listeners: {}
		config.listeners.change = @onChangeEvent
		config.listeners.blur = @onFieldBlur
		config.listeners.afterrender = @onAfterRender
		Ext.merge this, config
		if fieldProps.hasOwnProperty('editable')
			@editable = fieldProps.editable
		return


	configureTriggers: ->
		version = Ext.getVersion().major
		baseCSSPrefix = Ext.baseCSSPrefix

		@trigger2Cls = baseCSSPrefix + 'form-arrow-trigger'
		@onTrigger2Click = @onTriggerClick

		@triggerCls = baseCSSPrefix + 'form-clear-trigger'
		@onTriggerClick =  @onClearClick

		version = Corefw.util.Startup.getThemeVersion()
		if version is 2
			@triggerCls = 'formclearicon'
			@trigger2Cls = 'formtriggericon'

		return
	onTriggerClick: ->
		@callParent arguments
		@fieldEvent 'ONTRIGGER', this

	onAfterRender: ->
		if not @editable
			@hideClearButton()
		else
			@onChangeEvent()
		version = Corefw.util.Startup.getThemeVersion()
		if version is 2
			@triggerEl.elements[1].addCls 'combotrig'



	getFieldContainer: (field) ->
		return field.up('fieldset') or field.up('form') or field.up('coretoolbar')

	fieldEvent: (eventName, field) ->
		evt = Corefw.util.Event
		fieldContainer = @getFieldContainer(this)
		if fieldContainer.disableFormEvents
			return
		rq = Corefw.util.Request
		evt = Corefw.util.Event
		uip = Corefw.util.Uipath
		uipath = field.uipath


		field.valueChanged = true
		container = @getFieldContainer(field)
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


	onClearClick: ->
		return if @readOnly or @disabled
		@clearValue()
		@queryCache = []
		@fieldEvent 'ONCLEAR', this

	onChangeEvent: ->
		if (not @editable) or (not @rendered)
			return
		if Ext.isEmpty @value
			@hideClearButton()
		else
			@showClearButton()
		return

	hideClearButton: ->
		clearTrigger = @triggerEl.elements[0]
		clearTrigger.hide()
		clearTrigger.parent().setWidth  0

	showClearButton: ->
		clearTrigger = @triggerEl.elements[0]
		clearTrigger.show()
		clearTrigger.parent().setWidth  15

	onFieldBlur: ->
		return if @readOnly or @disabled
		@fieldEvent 'ONBLUR', this
		return

	clearValue: ->
		@setValue ''
		return

	generatePostData: ->
		value = @getValue()
		fieldObj =
			name: @name
			value: if Ext.isEmpty(value) then '' else value
		return fieldObj

