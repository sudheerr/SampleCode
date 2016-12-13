Ext.define 'Corefw.view.grid.hierarch.HierarchyGridBase',
	extend: 'Corefw.view.grid.GridBase'
	xtype: 'corehierarchygridbase'

	plugins: [
		ptype: 'rowexpander'
		rowBodyTpl: '<div class="hierarchygrid-rowexpanded" ></div>'
		expandOnDblClick: false
		selectRowOnExpand: false
		expandOnEnter: false

	]

	initComponent: ->
		@callParent arguments
		me = this

		@view.on 'expandbody', (rowNode, record, clickedRowDom, ev) ->
			me.expandOrCollapse me, rowNode, record, clickedRowDom, ev
		@view.on 'collapsebody', (rowNode, record, clickedRowDom, ev) ->
			me.expandOrCollapse me, rowNode, record, clickedRowDom, ev
		return


	expandOrCollapse: (comp, rowNode, record, clickedRowDom, ev) ->
		#cm = Corefw.util.Common
		newdiv = Ext.dom.Query.selectNode '.hierarchygrid-rowexpanded', clickedRowDom
		fieldCache = comp.up('corehierarchygrid').cache

		# data to be shown in this grid
		gridDataItems = record?.raw?._myProperties?.subGrid
		if not gridDataItems
			return

		# if clickedRowDom is not currently expanded, then create the grid
		if not clickedRowDom.expanded
			clickedRowDom.expanded = true

			cache = {}
			columnAr = []

			fieldProps = fieldCache._myProperties
			# hack since back end uipath not implemented for hierarchy grid
			uipath = fieldProps.uipath + '/subGrid' + record.raw.__index

			props =
				uipath: uipath
				parentGrid: comp
				columnAr: columnAr
				data: gridDataItems
				newdiv: newdiv

			cache._myProperties = props

			Corefw.view.grid.ObjectGrid.createDataCache gridDataItems, cache

			# create the columns of the subgrid
			columnsCache = fieldCache._myProperties.subContents
			for colCache in columnsCache
				newCache = {}
				newCache._myProperties = colCache
				columnAr.push colCache
				cache[colCache.name] = newCache

			config =
				cache: cache

			panel = Ext.create 'Corefw.view.grid.hierarch.HierarchyGridNode', config
			#record the expanded row index. to help sub grid to locate their selected status
			panel.expandedRowIndex = record.index
			clickedRowDom.panel = panel
		else
			# clickedRowDom is already expanded, now we want to destroy it
			clickedRowDom.panel.destroy()
			delete clickedRowDom.panel

			clickedRowDom.expanded = false

		return