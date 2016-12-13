###
	A grouped grid is actually a tree
	implements a tree with multiple columns, similar to a grid
	the tree is in the first column
###

Ext.define 'Corefw.view.tree.GroupedTreeGrid',
	extend: 'Corefw.view.tree.TreeFieldBase'
	xtype: 'coregroupedtreegrid'

	statics:
		createDataCache: (dataFieldItem, fieldCache) ->
			props = fieldCache?._myProperties
			props.data = props.values
			delete props.values
			return

	configureTree: ->
		#de = Corefw.util.Debug
		@callParent arguments

		treeCache = @cache
		# if de.printOutRawResponse()
		# 	console.log 'GroupedTreeGrid configure: cache: ',treeCache

		columns = []
		@treeConfig.columns = columns

		# configure the first column
		newColumnObj =
			xtype: 'treecolumn'
			width: 200
			dataIndex: 'text'

		columns.push newColumnObj


		# configure the remaining columns
		treeColumns = treeCache._myProperties.columnAr
		if treeColumns and treeColumns.length
			for column in treeColumns
				props = column._myProperties
				newColumnObj =
					text: props.title
					dataIndex: props.pathString
					width: 150

				columns.push newColumnObj
		return