Ext.define 'Corefw.view.tree.TreeBaseView',
	extend: 'Ext.tree.View'
	xtype: 'coretreebaseview'

# stripe rows when remove tree node
	onRemove: (ds, records, indexes) ->
		@callParent arguments
		@doStripeRows indexes[0]
		return