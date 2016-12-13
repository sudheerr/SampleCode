Ext.define 'Corefw.view.grid.pivot.PivotTableConfigPanel',
	alias: 'widget.pivottablecfgpanel'
	extend: 'Ext.panel.Panel'
	requires: [
		'Corefw.model.PivotConfig'
		'Corefw.mixin.Sharable'
	]
	mixins: ['Corefw.mixin.Sharable']
	dock: 'top'
	hidden: true
	ui: 'noborder'
	cls: 'pivottableCfgPanel'
	padding: 6
	globalFilterRecords: []
	items: [
		{
			xtype: 'coretoggleslidefield'
			fieldLabel: 'Apply Global Filter'
			itemId: 'glbFilterToggle'
			fieldCls: 'normalToggleLabel'
			labelCls: 'normalToggleLabelText'
			value: true
			hidden: true
			listeners: 
				beforerender: (me) ->
					su = Corefw.util.Startup
					me.toggle.onText = 'Yes'
					me.toggle.offText = 'No'
					onlabel = me.toggle.onLabel
					offlabel = me.toggle.offLabel
					return
			onToggleChange: (toggle, state) ->
				return
		}
		{
			xtype: 'panel'
			width: '100%'
			ui: 'noborder'
			layout:
				type: 'vbox'
				flex: 1
				align: 'stretch'
			defaults:
				xtype: 'container'
				layout:
					type: 'hbox'
					flex: 1
				minHeight: 150
			items: [
				{
					defaults:
						xtype: 'pivottablecfggrid'
						flex: 1
					items: [
						{
							margin: '0 3 0 0'
							cfgName: ['rowLabels', 'Row Labels']
							displaying: ['name', 'aggregate', 'sortby']
						}
						{
							margin: '0 0 0 3'
							cfgName: ['columnLabels', 'Column Labels']
							displaying: ['name', 'sortby']
						}
					]
				}
				{
					margin: '6 0 0 0'
					defaults:
						xtype: 'pivottablecfggrid'
						flex: 1
					items: [
						{
							margin: '0 3 0 0'
							xtype: 'filterCriteriaView'
							width: '100%'
							minHeight: 150
							headerText: 'Report Filter'
							enabledPlugins: [
								'filtermenufactory'
								'gridviewdragdrop'
							]
							isCriteriaGlobal: false
							extraListeners:
								beforedrop: (node, data, overModel, dropPosition, dropHandlers)->
									store = @getStore()
									dropHandlers.cancelDrop()
									if data.view.xtype is 'gridview'
										return				
									if data.records.length > 1
										Corefw.Msg.alert 'Error', 'Please select one node at a time'
										return
									newRecord = data.records[0]
									if not newRecord.isLeaf()
										Corefw.Msg.alert 'Error', 'Create filter on non-leaf node is not supported'
										return
									param =
										isMeasure: newRecord.isMeasure()
										dataTypeString: newRecord.get 'dataTypeString'
										pathString: newRecord.get 'path'
										showXY: [
											node.lastPageX
											node.lastPageY
										]
										itemName: newRecord.get 'text'
										underCollection: newRecord.get 'underCollection'
										repetitiveRatio: newRecord.get 'repetitiveRatio'
									@findPlugin('filtermenufactory').showFilterMenu param,
										domainName: @getShared('domainName')
						}
						{
							margin: '0 0 0 3'
							xtype: 'pivottablevaluescfggrid'
						}
					]
				}
			]
		}
		{
			xtype: 'container'
			layout:
				type: 'hbox'
				pack: 'end'
			cls: 'bottom-container'
			margin: '8 2 2 0'
			defaults:
				xtype: 'button'
				margin: '0 0 0 8'
				listeners:
					render: (me)->
						me.setUI 'primarybutton-small'
			items: [
				{
					text: 'Restore'
					hidden: true
				}
				{
					text: 'Save'
					handler: ->
						cfgpanel = @up 'pivottablecfgpanel'
						localCriteria = cfgpanel.down('filterCriteriaView').getStore().getCriteria() or []
						cfgpanel.store.getAt(0).filter().loadRawData localCriteria
						cfgpanel.store.each (record)->
							record.setDirty()
						cfgpanel.store.sync
							scope: this
							callback: @blur
				}
				{
					text: 'Update'
					handler: (silent) ->
						pivottable = @up('pivottable')
						cfgpanel = @up('pivottablecfgpanel')
						localCriteria = pivottable.down('filterCriteriaView').getStore().getCriteria() or []
						cfgpanel.store.getAt(0).filter().loadRawData localCriteria
						globalCriteria = cfgpanel.globalFilterRecords or []
						pivotConfig = cfgpanel.store.getProxy().getWriter().getRecordData cfgpanel.store.getAt(0)
						if cfgpanel.validate pivotConfig, silent
							pivottable.reload pivotConfig, globalCriteria
							pivottable.toggleConfigPanel false
						else
							pivottable.toggleConfigPanel true
				}
			]
		}
	]

	init: (griduipath)->
		@onSharedUpdate 'globalFilter', (globalFilterRecords)->
			@globalFilterRecords = globalFilterRecords
		@store = Ext.create 'Ext.data.Store',
			model: 'Corefw.model.PivotConfig'
			listeners:
				write: (store)->
					store.each (record)->
						record.associations.each (association)->
							record[association.name]().commitChanges()
		@store.getProxy().getWriter().extraJsonData = uipath: griduipath
		@store.load
			params:
				uipath: griduipath
			scope: this
			callback: ->
				pivotCfgRec = @store.getAt 0
				grids = {}
				for grid in @query 'pivottablecfggrid'
					grids[grid.getGridName()] = grid
					grid.bindStore pivotCfgRec[grid.getGridName()]()
				grids['rowLabels'].sharedUniqueness = 'column labels': grids['columnLabels'].getStore()
				grids['columnLabels'].sharedUniqueness = 'row labels': grids['rowLabels'].getStore()
				pivotCfgRec.filter().filterOnLoad = false
				@down('filterCriteriaView').store.loadRecords pivotCfgRec.filter().getRange()
				@down('[text=Update]').handler true

	listeners:
		beforehide: (me)->
			editor = @down 'editor'
			editor.completeEdit() if editor

	getArrCnt: (arr)->
		if arr then arr.length else 0

	validators: [
		['Both row labels and column labels are empty.', (cfg)->
			@getArrCnt(cfg.rowLabels) isnt 0 or @getArrCnt(cfg.columnLabels) isnt 0]
		['Both row labels and values are empty', (cfg)->
			@getArrCnt(cfg.rowLabels) isnt 0 or @getArrCnt(cfg.values) isnt 0]
	]
	validate: (cfg, silent)->
		for validator in @validators
			if not validator[1].call this, cfg
				Corefw.Msg.alert 'Invalid Config', validator[0] if silent isnt true
				return false
		return true