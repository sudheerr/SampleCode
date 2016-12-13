Ext.define 'Corefw.view.filter.CriteriaView',
	extend: 'Corefw.view.filter.ViewBase'
	alias: 'widget.filterCriteriaView'
	requires: [
		'Corefw.view.filter.plugin.FilterViewDD'
		'Corefw.view.filter.plugin.MenuFactory'
	]
	enabledPlugins: [
		'filterviewdragdrop'
		'filtermenufactory'
	]
	allPlugins: 
		filterviewdragdrop:
			ptype: 'filterviewdragdrop'
			enableDrag: true
		filtermenufactory:
			ptype: 'filtermenufactory'
			triggerEvent: null
		gridviewdragdrop:
			ptype: 'gridviewdragdrop'
			enableDrag: false
			ddGroup: 'treeDrop'
	mixins: [
		'Corefw.mixin.Sharable'
	]
	deferEmptyText: false
	maxHeight: 220
	autoScroll: true

	initComponent: ->
		@plugins = []
		for plugin in @enabledPlugins
			@plugins.push @allPlugins[plugin]
		@callParent arguments
		@on 'afterrender', ->
			@bindFilterStore @getStore()

	afterClickFilterIcon: (record, item, position) ->
		criteria = record.get 'operandsString'
		underCollection = false
		param = undefined
		criteria = if criteria.length is 0 then [ '' ] else criteria
		if criteria[0].operator
			underCollection = true
		param =
			isMeasure: record.get 'measure'
			dataTypeString: record.get 'dataTypeString'
			pathString: record.get 'pathString'
			itemName: record.get 'itemName'
			showXY: position
			underCollection: underCollection
			triggerOwner: record
		@findPlugin('filtermenufactory').showFilterMenu param, domainName: @getShared('domainName')
		return