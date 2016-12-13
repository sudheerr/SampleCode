Ext.define 'Corefw.view.grid.pivot.plugin.CellTooltip',
	extend: 'Ext.AbstractPlugin'
	alias: 'plugin.pivotcelltooltip'

	# Initialize this as a plugin
	init: (grid)->
		me = this
		me.grid = grid
		me.view = grid.view
		me.viewListeners = me.view.on 'afterrender', me.createToolTip, me
		me.gridListeners = me.grid.on 'reconfigure', me.onReconfigure, me

	onReconfigure: (grid, store)->

	createToolTip: (view)->
		@tip = Ext.create 'Ext.tip.ToolTip',
			grid: @grid
			target: view.el
			delegate: view.cellSelector
			dismissDelay: 15000
			renderTo: Ext.getBody()
			listeners:
				beforeshow: (tip)->
					grid = @grid
					cell = tip.triggerElement
					row = tip.triggerElement.parentElement
					column = view.getHeaderByCell cell
					record = view.getRecord row
					rowLabelsText = Ext.Array.map grid.currentPivotConfig.rowLabels, (l)-> record.get(l.path)
					rowLabelsText = Ext.Array.filter(rowLabelsText, (t)-> t).join ' - '
					clvalues = column.dataIndex.split grid.keyDelimeter
					if column.xtype is 'pivotvaluecolumn'
						clvalues = clvalues.splice(0, clvalues.length-2).join ' - '
					else if column.xtype is 'pivotgroupcolumn'
						clvalues = clvalues.join ' - '
					else
						return false
					tipText = [
						"<b>#{column.text}</b>"
						"Value: #{record.get(column.dataIndex)}"
						"Row: #{rowLabelsText}"
						"Column: #{clvalues}"
					]
					tip.update tipText.join('<br>')