Ext.define 'Corefw.view.grid.pivot.PivotTableValuesConfigGrid',
	alias: 'widget.pivottablevaluescfggrid'
	extend: 'Corefw.view.grid.pivot.PivotTableConfigGrid'
	cfgName: ['values', 'Values']
	displaying: ['name', 'aggregation']
	model: 'Corefw.model.PivotValueConfigItem'
	mixins: ['Corefw.mixin.Sharable']
	varianceTypesMenuConfig:
		items: [
			{
				text: 'DifferencePercentage'
			}
			{
				text: 'DifferenceValue'
			}
			{
				text: 'ActualValue'
			}
			{
				text: 'AbsoluteDiffValue'
			}
		]
		listeners:
			click: (menu, item) ->
				varianceType = CorefwFormatter.varianceMap[item.text]
				timePoint = menu.parentItem.realValue
				menu.up('[name=variancePicker]').handleVariance varianceType, timePoint

	recordValidate: (newRecord, draggedRecord) ->
		return [draggedRecord.get('measure'), 'Only Measure can be values']

	showVarianceMenu: (timeMarks, record, posXY) ->
		gridStore = @getStore()
		menu = Ext.create 'Ext.menu.Menu',
			name: 'variancePicker'
			handleVariance: (varianceType, timePoint) ->
				recData = Ext.apply record.getData(),
					valueItemId: ''
					fullText: ''
					timeMarks: timeMarks
					variance: true
					varianceType: varianceType
					varianceTimeMark: timePoint 
				gridStore.add recData
		for freq, freqObj of timeMarks
			freqMenu = items: []
			for timePoint, item of freqObj
				freqMenu.items.push
					cls: 'icon-next_lvl_menu'
					text: "#{item.relative} #{item.formatted}"
					realValue: timePoint
					menu: @varianceTypesMenuConfig
			menu.add
				cls: 'icon-next_lvl_menu'
				text: freq
				menu: freqMenu
		menu.showAt posXY

	addingVariance: (record, posXY) ->
		@getShared('reqTimeMarks') @showVarianceMenu, this, record, posXY

	bindStore: (store, initial) ->
		@callParent arguments
		if not initial
			@getShared('reqTimeMarks') (timeMarks) ->
				@getStore().each (record) ->
					record.set 'timeMarks', timeMarks
					record.calcFields()
			, this

	getColumnsMapping: ->
		return Ext.apply Ext.clone(@columnsMapping), @valuesColumnsMapping

	valuesColumnsMapping:
		name:
			menuDisabled: true
			text: ''
			dataIndex: 'fullText'
			flex: 1
		action:
			menuDisabled: true
			xtype: 'actioncolumn'
			width: 50
			items: [{
				iconCls: 'icon-plus'
				tooltip: 'Add Variance'
				handler: (view, rowIndex, colIndex, item, e, record) ->
					view.up('grid').addingVariance record, e.getXY()
				isDisabled: (view, rowIndex, colIndex, item, record) ->
					return record.get 'variance'
			}
			{
				iconCls: 'icon-delete'
				tooltip: 'Delete'
				handler: (view, rowIndex)->
					view.getStore().removeAt rowIndex
			}
			]