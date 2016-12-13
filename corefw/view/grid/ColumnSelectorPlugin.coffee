Ext.define 'Corefw.view.grid.ColumnSelectorPlugin',
	extend: 'Ext.AbstractPlugin'
	alias: 'plugin.columnselectorplugin'
	init: (parent)->
		parent.columnSelector =
			selected: []
			singleSelect: (column)->
				@iteratorColumnCell column, (view, cell)->
					cell.addCls view.selectedCellCls
					return
				@selected.push column
				column.selected = true
				column.active = true
				return
			singleDeselect: (column)->
				@iteratorColumnCell column, (view, cell)->
					cell.removeCls view.selectedCellCls
					return
				Ext.Array.remove @selected, column
				column.selected = false
				column.active = false
				return
			doSelect: (column)->
				subColumns = column.getGridColumns()
				if subColumns.length
					for subCol in subColumns
						@singleSelect subCol
				else
					@singleSelect column
				return
			doDeselect: (column)->
				subColumns = column.getGridColumns()
				if subColumns.length
					for subCol in subColumns
						@singleDeselect subCol
				else
					@singleDeselect column
				return
			deselectAll: ()->
				while @selected.length
					@doDeselect @selected[0]
				return
			iteratorColumnCell: (column, fn)->
				view = parent.getView()
				if view.getViewForColumn
					view = view.getViewForColumn column
				position =
					column: column.getIndex()
					row: 0
				cell = view.getCellByPosition position
				while cell
					fn view, cell
					position.row++
					cell = view.getCellByPosition position
				return

		parent.on "headerclick", (ct, column, ev, t, opts)->
			columnSelector = parent.columnSelector
			if not ev.ctrlKey
				columnSelector.deselectAll()
			else
				columnSelector.doSelect column
			return

		columnSortableMap = {}
		parent.on "afterrender", ()->
			columns = parent.headerCt.getGridColumns()
			for col in columns
				columnSortableMap[col.id] = col.sortable
			return

		keydownHandler = (e)->
			if e.keyCode is Ext.EventObject.CTRL
				columns = parent.headerCt.getGridColumns()
				for col in columns
					col.sortable = false
			return
		keyupHandler = (e)->
			if e.keyCode is Ext.EventObject.CTRL
				columns = parent.headerCt.getGridColumns()
				for col in columns
					col.sortable = columnSortableMap[col.id]
			return
		Ext.getDoc().on "keydown", keydownHandler
		Ext.getDoc().on "keyup", keyupHandler

		parent.on "destroy", ()->
			Ext.getDoc().un "keydown", keydownHandler
			Ext.getDoc().un "keyup", keyupHandler
			return
		return