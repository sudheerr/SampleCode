###
	base class for all grids that need to be in a field container,
		i.e., any grids found in a form
###

Ext.define 'Corefw.view.grid.GridFieldBase',
	extend: 'Ext.form.FieldContainer'
	xtype: 'coregridfieldbase'

	padding: 0
	border: 0
	layout: 'fit'
	flex: 1
	hideLabel: true

	onResize: ->
		if @alreadyResized
			delete @alreadyResized
			return

		@alreadyResized = true
		@callParent arguments
		return

# add an embedded grid to this container
	addGrid: (grid) ->
		@items = [
			grid
		]
		@grid = grid
		grid.parentComponent = this

		return

# seeing if filterType is enable for any column in the grid
	isFilterEnabledForAnyColumn: (fieldItems) ->
		enabledforcolumn = false
		Ext.each fieldItems, (item) ->
			if typeof item._myProperties.filterType isnt 'undefined'
				enabledforcolumn = true
			return

		return enabledforcolumn