Ext.define 'Corefw.view.filter.plugin.MenuFactory',
	extend: 'Ext.AbstractPlugin'
	alias: 'plugin.filtermenufactory'

	triggerEvent: 'itemdblclick'

	beforecreate: null
	extraParams: null

	menuInstances: {}

	init: (client) ->
		@client = client
		@client.bindFilterStore = (store)->
			@filterStore = store
		if @triggerEvent
			@client.on @triggerEvent, @createHandler, this

	createHandler: ->
		if not @client.filterStore
			Corefw.Msg.alert 'Error', 'Filter store is not bound, cannot create filter menu.'
			return
		if @beforecreate and not @beforecreate.apply @client, arguments
			return
		fn = this["on#{@triggerEvent}"]
		if fn
			fn.apply this, arguments

	onitemdblclick: (view, record, item, index, e, eOpts) ->
		param =
			isMeasure: record.isMeasure()
			dataTypeString: record.get 'dataTypeString'
			pathString: record.get 'path'
			showXY: [
				25
				e.getY() + 10
			]
			itemName: record.get 'text'
			underCollection: record.get 'underCollection'
			repetitiveRatio: record.get 'repetitiveRatio'
		extraParams = @extraParams
		if Ext.isFunction extraParams
			extraParams = extraParams.apply @client, arguments
		@showFilterMenu param, extraParams

	showFilterMenu: (param, extraParams)->
		isMeasure = param.isMeasure
		dataTypeString = param.dataTypeString
		pathString = param.pathString
		showXY = param.showXY
		underCollection = param.underCollection
		triggerOwner = param.triggerOwner
		repetitiveRatio = param.repetitiveRatio
		menu = undefined
		filterStore = @client.filterStore
		isTimeMark = filterStore.isTimeMarkPath(pathString) or filterStore.isTimeMarkCriteriaPath(pathString)
		isDate = dataTypeString is 'date'
		if underCollection
			menu = @getMenu 'Corefw.view.filter.menu.Collection'
		else if isTimeMark
			menu = @getMenu 'Corefw.view.filter.menu.TimeMark'
		else if isDate
			menu = @getMenu 'Corefw.view.filter.menu.Date'
		else if Ext.Array.contains ["int", "float"], dataTypeString
			menu = @getMenu 'Corefw.view.filter.menu.Number'
		else
			menu = @getMenu 'Corefw.view.filter.menu.String'
			menu.setCurrentColumnPath pathString
		Ext.apply menu, criteriaStore: filterStore
		menu.clearMenu()
		menu.setFilterMenuComboStore menu, pathString, extraParams
		#triggerOwner could be a Corefw.model.FilterCriteria instance or a column, 
		#if record and a column are both needed, the caller will both pass triggerOwner as a column, record as a Corefw.model.FilterCriteria instance
		if param.triggerOwner instanceof CorefwFilterModel
			menu.setRecord param.triggerOwner
		else if param.record instanceof CorefwFilterModel
			menu.setRecord param.record
		menu.setFilterPath pathString
		menu.setItemName if param.itemName then param.itemName else ''
		menu.dataTypeString = dataTypeString
		menu.triggerOwner = triggerOwner
		menu.showAt showXY
		menu.repetitiveRatio = repetitiveRatio

	getMenu: (menuType)->
		if not @menuInstances[menuType]
			@menuInstances[menuType] = Ext.create menuType
		return @menuInstances[menuType]

	destroy: ->
		for menuType, menu of @menuInstances
			menu.destroy()