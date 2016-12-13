Ext.define 'Corefw.view.grid.BufferedRenderer',
	extend: 'Ext.grid.plugin.BufferedRenderer'
	alias: 'plugin.corebufferedRenderer'

	setBodyTop: ( bodyTop, calculatedTop )->
		me = @
		bodyDom = me.view.body.dom
		if bodyDom is undefined
			return
		@callParent arguments
		return

	onViewScroll: ->
		@callParent arguments
		coregrid = this.grid.up 'coretreegrid, coreobjectgrid'
		if not coregrid
			return

		# sync row height if grid has locked grid 
		gridbase = coregrid.down()
		if gridbase.lockedGrid and gridbase.syncRowHeight
			gridbase.syncRowHeights()

		# apply style
		uipath = coregrid.uipath
		if uipath
			myFunc = Ext.Function.createBuffered ->
				# grid will be replaced, so previous grid reference may be not the correct one on the page.
				# here hack to use uipath query to ensure working. later refactor
				coregrid = Ext.ComponentQuery.query('[uipath=' + uipath + ']')[0]
				if coregrid
					grid = coregrid.down()
					grid.styleDecorate?()
				return
			, 400
			myFunc()
		return

	onStoreClear: ->
		return
