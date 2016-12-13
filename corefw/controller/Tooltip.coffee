Ext.define 'Corefw.controller.Tooltip',
	extend: 'Ext.app.Controller'

	init: ->
		@control
			"gridview":
				refresh: @onGridViewRefresh
		return

	onGridViewRefresh: (gridview, eOpts) ->
		fieldContainer = gridview.up('fieldcontainer')
		pFieldCtProps = fieldContainer?.cache._myProperties
		grid = gridview.up 'grid'
		return if not pFieldCtProps
		widgetType = pFieldCtProps.widgetType
		switch widgetType
			when 'OBJECT_GRID'
				tooltipData = pFieldCtProps.items
				@createToolTipOnGrid grid, pFieldCtProps, tooltipData
			when 'TREE_GRID'
				@createToolTipOnTreeGrid fieldContainer
			when 'RCGRID'
				tooltipData = pFieldCtProps.tooltipValue or {}
				@createToolTipOnGrid grid, pFieldCtProps, tooltipData
				@bindStyleToGrid grid, pFieldCtProps
		return

	createToolTipOnGrid: (grid, pFieldCtProps, tooltipData)->
		return if not tooltipData
		st = grid.store
		return if not st or not st.data
		su = Corefw.util.Startup
		delayToolTips = su.getStartupObj().delayTooltips == true
		columns = grid.columns
		view = grid.getView()
		rowRecords = view.getViewRange()
		loopCells = @loopCells
		for rowRecord,index in rowRecords
			tooltipValue = tooltipData[index]?.tooltipValue # object grid
			tooltipValue = tooltipData[index]?.cells if not tooltipValue # rc grid
			continue if not tooltipValue
			loopCells view, rowRecord, columns, (column, cell) ->
				pathString = column.pathString
				tooltip = tooltipValue[pathString]?.tooltip
				if cell?.dom and not Ext.isEmpty tooltip
					cell?.dom.tooltip = tooltip
				return
		Ext.create 'Ext.tip.ToolTip',
			dismissDelay: 0
			target: view.el
			delegate: view.cellSelector
			renderTo: Ext.getBody()
			hideDelay: if delayToolTips == true then 1200 else 200
			listeners:
				beforeshow: (tip) ->
					tooltip = tip.triggerElement?.tooltip
					# To show tooltip when data is truncated in the cell.
					if not tooltip
						cmp = Ext.get(tip.triggerElement.id)
						if cmp and not cmp.isTooltipCreated
							txtC = tip.triggerElement.textContent
							if not @textMetrics
								@textMetrics = new Ext.util.TextMetrics()

							cellValue = ((@textMetrics.getSize(txtC).width) + 2) or 0
							if cmp.getWidth() < cellValue
								tooltip = tip.triggerElement.textContent;

					if not tooltip
						return false
					visibleTooltips = Ext.ComponentQuery.query "tooltip[hidden=false]"
					for visibleTooltip, id in visibleTooltips
						visibleTooltip.hide()
					tip.update tooltip
					return
				click:
					element: 'el'
					fn: (el) ->
						Ext.getCmp(@id).showAt @getXY
						return
		return

# fieldContainer: up to field container component
# TODO tooltip re-factoring
	createToolTipOnTreeGrid: (fieldContainer)->
		tree = fieldContainer.tree
		#grid = fieldContainer.down 'grid'
		treeStore = tree.store.tree
		return if treeStore.root.childNodes.length is 0

		nodeHash = treeStore.nodeHash
		pFieldCtProps = fieldContainer.cache._myProperties
		return if not pFieldCtProps.data
		cm = Corefw.util.Common
		rowsData = cm.converTreeGridDataToDataList pFieldCtProps.data
		columns = tree.columns
		view = tree.getView()
		createToolTipOnCell = @createToolTipOnCell
		loopCells = @loopCells
		createToolTip = @createToolTip
		for key, node of nodeHash
			continue if key is 'root'
			tooltipValueObj = rowsData[node.raw.__index]?.tooltipValue
			continue if not tooltipValueObj
			loopCells view, node, columns, (column, cell) ->
				createToolTipOnCell column, cell, tooltipValueObj, createToolTip
				return
		return

	loopCells: (view, row, columns, processor)->
		for column in columns
			#dataIndex = column.dataIndex
			continue if not view.getNode row, true
			cell = view.getCell row, column
			processor? column, cell if cell
		return

	createToolTipOnCell: (column, cell, tooltipValueObj, createToolTipFn) ->
		pathString = column.pathString
		tooltip = tooltipValueObj[pathString]?.tooltip
		cell.isTooltipCreated = cell.isTooltipCreated || false
		if cell and cell.isTooltipCreated is false and not Ext.isEmpty tooltip
			createToolTipFn cell, tooltip
			cell.isTooltipCreated = true
		return

	createToolTip: (target, html) ->
		Ext.create 'Ext.tip.ToolTip',
			dismissDelay: 0
			target: target
			html: html

# TODO:will be removed to style js
	bindStyleToGrid: (grid, pFieldCtProps) ->
		st = grid.store
		return if not st or not st.data
		fn = Ext.Function.createDelayed ->
			view = grid.getView()
			cols = grid.columns
			rowData = pFieldCtProps.tooltipValue
			rowArray = st.data?.items?

			if rowArray
				for record , index in rowArray
					cells = rowData[index].cells
					for col in cols
						dataIndex = col.dataIndex
						style = cells?[dataIndex]
						if not style
							continue
						cell = view.getCell record, col
						if cell
							if style.cellStyle
								cell.addCls style.cellStyle

							if style.rowStyle
								cell.parent().addCls style.rowStyle
								lockedview = grid.getView().lockedView
								if lockedview
									cell = lockedview.getCell record, cols[0]
									if cell
										tr = cell.parent().dom
										tr.className = tr.className + ' ' + style.rowStyle
			return
		, 800
		fn()
		return