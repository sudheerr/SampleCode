Ext.define 'Corefw.view.tree.CheckboxColumn',
	extend: 'Ext.tree.Column'
	xtype: 'treecheckboxcolumn'

	treeRenderer: (value, metaData, record) ->
		output = @callParent arguments
		replaceStr = 'treenode-disabled x-tree-checkbox" disabled'
		if record?.raw?.disabled
			output = output.replace /x-tree-checkbox"/g, replaceStr
		return output