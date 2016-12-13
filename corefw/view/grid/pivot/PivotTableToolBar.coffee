Ext.define 'Corefw.view.grid.pivot.PivotTableToolBar',
	extend: 'Ext.toolbar.Toolbar'
	alias: 'widget.pivottabletoolbar'
	dock: 'top'
	titleMargin: null
	iconMenuSize: null
	items: [
		{
			xtype: 'label'
			cls: 'panel-title'
			margin: '0 0 0 10'
			text: 'Pivot Data'
		}
		{
			xtype: 'tbtext'
			cls: 'toolbar-spliter'
			name: 'title-spliter'
		}
		{
			xtype: 'button'
			scale: 'medium'
			iconCls: 'I_SETTINGS icon-settings'
			name: 'config'
			border: 0
			tooltip: 'Configuration'
			handler: (b, e) ->
				pivottable = @up 'pivottable'
				if not pivottable.toggleConfigPanel()
					b.blur()
				return
		}
		{
			xtype: 'label'
			text: 'in'
			name: 'label-in'
		}
		{
			xtype: 'combo'
			name: 'denomination'
			width: 50
			align: 'right'
			cls: 'denomination-combo'
			value: 1
			store: [
				[1, '$']
				[1000, '$M']
				[1000000, '$MM']
				[1000000000, '$B']
			]
			listeners:
				change: (me, newValue)->
					me.up('pivottable').updateDivisor newValue
		}
		{
			xtype: 'button'
			border: 0
			scale: 'medium'
			iconCls: 'I_EXCEL icon-download'
			tooltip: 'Download'
			handler: (b, e) ->
				pivottable = @up 'pivottable'
				Corefw.util.Common.download
					generatePostParams: ->
						uipath: pivottable.uipath
						fileExtension: '.xlsx'
					, 'api/pivot/pivotData/download'
				return
		}
		'->'
		{
			xtype: 'label'
			name: 'rows'
			text: ''
			margin: '0 8 0 0'
			update: (totalRows)->
				@setText "Total #{totalRows} Rows"
		}
	]
	setDenomination: (denomination) ->
		@down('combo[name=denomination]').setValue domination
		return