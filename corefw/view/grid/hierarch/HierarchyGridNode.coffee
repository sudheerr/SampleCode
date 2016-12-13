###
	Defines a grid to be shown as a row under the main grid row
	Activated by clicking on the expand/collapse icon to show the grid.
###
Ext.define 'Corefw.view.grid.hierarch.HierarchyGridNode',
	extend: 'Corefw.view.grid.GridBase'
	xtype: 'corehierarchygridnode'

	initComponent: ->
		@initializeHierarchyNode()

		@callParent arguments
		return


	initializeHierarchyNode: ->
		cache = @cache
		props = cache._myProperties

		config =
			renderTo: props.newdiv
			autoDestroy: true

		Ext.apply this, config


		return
