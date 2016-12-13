Ext.define 'Corefw.view.grid.pivot.PivotTableConfigGrid',
	alias: 'widget.pivottablecfggrid'
	extend: 'Ext.grid.Panel'
	requires: [
		'Corefw.model.FilterCriteria'
		'Corefw.model.PivotConfigItem'
	]
	model: 'Corefw.model.PivotConfigItem'
	height: '100%'
	minHeight: 105
	selType: 'cellmodel'
	sharedUniqueness: {}
	plugins:
		ptype: 'cellediting'
		clicksToEdit: 1
	viewConfig:
		plugins:
			ptype: 'gridviewdragdrop'
			dragText: 'Drag and drop to reorganize'
			ddGroup: 'treeDrop'
		listeners:
			beforedrop: (node, data, overModel, dropPosition, dropHandlers) ->
				store = @getStore()
				sameType = data.view.xtype is @xtype
				if sameType
					validDrop = true
					procRecord = (record, sameView) ->
						if not sameView
							[valid, reason] = @up('grid').recordValidate null, record, sameType
							if not valid
								validDrop = false
								Corefw.Msg.alert 'Invalid Config', reason if reason
								return
						if record is store.last()
							index = store.indexOf overModel
							index++ if dropPosition is 'after'
							record.set 'aggregate', store.getAt(index).get('aggregate')
					for record in data.records
						procRecord.call this, record, data.view is @view
					if validDrop
						dropHandlers.processDrop()
					else
						dropHandlers.cancelDrop()
				else
					leafRecords = []
					data.records.forEach (record) ->
						if record.isLeaf()
							leafRecords.push record
						else if Ext.isArray record.childNodes
							leafRecords = leafRecords.concat record.childNodes.filter (node) -> node.isLeaf()
					leafRecords.forEach (record) ->
						gridRecord = Ext.create @up('grid').model
						gridRecord.copyFrom record, name: 'text'
						[valid, reason] = @up('grid').recordValidate gridRecord, record
						if not valid
							Corefw.Msg.alert 'Invalid Config', reason if reason
							return
						index = store.indexOf overModel
						if index isnt -1
							index++ if dropPosition is 'after'
							store.insert index, gridRecord
						else
							store.add gridRecord
					, this
					dropHandlers.cancelDrop()
			drop: (node, data, overModel, dropPosition) ->
				# TBD, cellModel selection is messed up after drop
				# when the dropped record is dragged & dropped in another place
				# cellModel failed in its onViewRefresh() method
				# below is a temp fix
				@getSelectionModel().select @getStore().getCount() - 1, false, false
				return

	constructor: (config) ->
		@columns = []
		cfgName = config.cfgName or @cfgName
		for col in config.displaying or @displaying
			colDef = @getColumnsMapping()[col]
			if colDef.comboEditor
				storeMeta = colDef.comboEditor
				storeMeta = storeMeta() if Ext.isFunction storeMeta
				colDef.editor = Ext.create 'Ext.form.field.ComboBox', 
					typeAhead: true
					triggerAction: 'all'
					selectOnTab: true
					store: storeMeta
					lazyRender: true
			colDef.text = cfgName[1] if col is 'name'
			@columns.push colDef
		@columns.push @getColumnsMapping().action
		@callParent arguments

	getGridName: ->
		return @cfgName[0]

	bindStore: (store) ->
		@callParent arguments
		@mon store,
			add: @onStoreChange
			remove: @onStoreChange
			scope: this

	onStoreChange: ->
		records = @getStore().getRange()
		if records.length
			lastRecord = records[records.length-1]
			penultimateRecord = records[records.length-2]
			lastRecord.set 'aggregate', false
			@view.refreshNode @getStore().indexOf(lastRecord)
			@view.refreshNode @getStore().indexOf(penultimateRecord) if penultimateRecord

	recordValidate: (newRecord, draggedRecord, sameType) ->
		return [true] if sameType
		for scopeName, store of @sharedUniqueness
			exists = store.indexOfId(newRecord.get('path')) > -1
			return [false, "This item is already in #{scopeName}"] if exists
		return [@getStore().indexOfId(newRecord.get('path')) is -1]

	getColumnsMapping: ->
		return @columnsMapping

	columnsMapping:
		name:
			menuDisabled: true
			text: ''
			dataIndex: 'name'
			flex: 1
		aggregate:
			menuDisabled: true
			xtype: 'pivotcfgcheckcolumn'
			text: 'Subtotal'
			dataIndex: 'aggregate'
		sortby:
			menuDisabled: true
			xtype: 'gridcolumn'
			text: 'Sort By'
			dataIndex: 'sortby'
			comboEditor: ['ASC', 'DESC']
		aggregation:
			menuDisabled: true
			text: 'Aggregation'
			dataIndex: 'aggregation'
			comboEditor: ['Sum', 'Average', 'Count', 'Max', 'Min']
		action:
			menuDisabled: true
			xtype: 'actioncolumn'
			width: 50
			items: [{
				iconCls: 'icon-delete'
				tooltip: 'Delete'
				handler: (grid, rowIndex)->
					grid.getStore().removeAt rowIndex
			}]