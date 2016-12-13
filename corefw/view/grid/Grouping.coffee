# this class is necessary because we need to move the save/update buttons
#		to support textarea editing in the grid, which changes the height of the editor

Ext.define 'Corefw.view.grid.Grouping',
	extend: 'Ext.grid.feature.GroupingSummary'
	xtype: 'coregrouping'
	alias: 'feature.coregroupingsummary',
	afterViewRender: ()->
		me = this
		view = me.view
		view.on({
			scope: me,
			groupclick: me.onGroupClick
		})
		if me.enableGroupingMenu
			me.injectGroupingMenu()
		#me.pruneGroupedHeader()
		me.lastGroupField = me.getGroupField()
		me.block()
		#me.onGroupChange()
		me.unblock()

