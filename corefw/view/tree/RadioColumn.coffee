Ext.define 'Corefw.view.tree.RadioColumn',
	extend: 'Ext.tree.Column'
	xtype: 'treeradiocolumn'


	treeRenderer: (value, metaData, record) ->
		disabled = record.raw.disabled
		if disabled
			record.set('checked', false)
		output = @callParent arguments
		if not record.isLeaf()
			startIndex = output.indexOf '<input type="button" role="checkbox"'
			radioHtml = output.substr startIndex, output.substr(startIndex, output.length).indexOf('/>') + 2
			output = output.replace radioHtml, ''
		else
			replaceStr = 'tree-radioselect'
			# sigh: total hack: change tree-checkbox class to radio button class
			output = output.replace /tree-checkbox /g, replaceStr + ' '
			output = output.replace /tree-checkbox"/g, replaceStr + '"'
		return output