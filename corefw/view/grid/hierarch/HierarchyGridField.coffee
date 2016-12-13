Ext.define 'Corefw.view.grid.hierarch.HierarchyGridField',
	extend: 'Corefw.view.grid.ObjectGrid'
	xtype: 'corehierarchygrid'

	onRender: ->
		@callParent arguments
		@grid.maxHeight = @maxHeight - 10
		@grid.setHeight @maxHeight - 10

		return

	generatePostData: (expandedRowIndex, selectedRecord) ->
		postData = @grid.generatePostData()
		cm = Corefw.util.Common;
		cache = cm.objectClone this.cache
		subGridWithIndex = {}
		for item in cache._myProperties.items
			if not item.subGrid
				return postData
			subGridWithIndex[item.index] = item.subGrid

		for postItem in postData.items
			postItem.subGrid = subGridWithIndex[postItem.index]
			for subGridItem in postItem.subGrid.items
				# find the selected item in the subGrid
				if  selectedRecord and expandedRowIndex is postItem.index and subGridItem.index is selectedRecord.index
					subGridItem.selected = true
				delete subGridItem.messages
		return postData