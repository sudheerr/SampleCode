Ext.define 'Corefw.view.grid.CheckboxModel',
	extend: 'Ext.selection.CheckboxModel'
	alias: 'selection.corecheckboxmodel'

	isSelectedAll: false
	buffered: false

	doDeselect: (records, keepExisting, suppressEvent) ->
		gridProps = @getGridProps()
		gridProps?.selectedAll = false
		if gridProps?.infinity
			@preventFocus = true
		if not gridProps?.enableAutoSelectAll and not suppressEvent
			@preventFocus = undefined
			@isSelectedAll = false
		ret = @callParent arguments
		if gridProps?.infinity
			@preventFocus = undefined
			@isSelectedAll = false

		return ret

	doSelect: (records, keepExisting, suppressEvent) ->
		gridProps = @getGridProps()
		if gridProps?.infinity
			@preventFocus = true
		if not gridProps?.enableAutoSelectAll and not suppressEvent
			@preventFocus = undefined
			@isSelectedAll = false
		@callParent arguments
		if gridProps?.infinity
			@preventFocus = undefined

		return

	updateHeaderState: ->
		@callParent arguments
		gridProps = @getGridProps()
		if gridProps?.buffered and @getSelColumn().selectAllScope is 'GRID'
			@getSelColumn().updateState gridProps
			if not gridProps.selectedAll
				@toggleUiHeader false
			return
		if (gridProps?.infinity or not gridProps?.enableAutoSelectAll) and not @isSelectedAll
			@toggleUiHeader false
			@isSelectedAll = false
		return

	getGridProps: ->
		gridbase = @view.up('coreobjectgrid')
		gridProps = gridbase?.grid.cache._myProperties
		return gridProps

	getSelColumn: ->
		return @view.up('coreobjectgrid').down 'coreselectcolumn'

#override onHeaderClick to process ONSELECTALL/ONDESELECTALL Events
	onHeaderClick: (headerCt, header, e) ->
		props = @getGridProps()
		suppressEvents = false
		grid = undefined
		selectable = true
		if header.isCheckerHd
			e.stopEvent()
			me = this
			isChecked = header.el.hasCls(Ext.baseCSSPrefix + 'grid-hd-checker-on')
			# Prevent focus changes on the view, since we're selecting/deselecting all records
			me.preventFocus = true
			container = header.up('fieldcontainer')
			isTreeGrid = container.tree
			if props.buffered and @getSelColumn().selectAllScope is 'GRID'
				@getSelColumn().selectAllChange isChecked
			if not isTreeGrid
				grid = container.grid
				#Making sure none of the records selectable property is set to false.
				#If false, the checkbox is disabled and hence we should not fire the event.
				grid.getStore().data.each ->
					if @data._myProperties.selectable is false
						selectable = false
						return selectable
			else
				grid = container.tree
				grid.traverseNodes grid.cache._myProperties.allTopLevelNodes, 'children', (n) ->
					selectable = false if n.selectable is false
			#Select/DeSelect events will be suppressed only when the grid has ONSELECTALL/ONDESELECTALL
			#All the records have to be selectable too.
			if isChecked
				@isSelectedAll = false
				props?.selectedAll = false
				if selectable and props.events['ONDESELECTALL']
					suppressEvents = true
				me.deselectAll suppressEvents
			else
				@isSelectedAll = true
				props?.selectedAll = true
				if selectable and props.events['ONSELECTALL']
					suppressEvents = true
				if props?.enableAutoSelectAll is false
					me.selectAll true
				else
					me.selectAll suppressEvents
			delete me.preventFocus

			# if the select/deselect events are suppresed we  need to fire selectall/deselectall
			if suppressEvents
				if isChecked
					grid.fireEvent 'deselectall', container, 'ONDESELECTALL', {}
				else
					grid.fireEvent 'selectall', container, 'ONSELECTALL', {}
				return false

	renderer: (value, metaData, record, rowIndex, colIndex, store, view) ->
		@callParent arguments
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			if record?.raw?._myProperties?.selectable is false
				return '<div class="' + Ext.baseCSSPrefix + 'grid-row-checker selectmodel-item-disabled ' + Ext.baseCSSPrefix + 'grid-checkselect" role="presentation">&#160;</div>'
			else
				return '<div class="' + Ext.baseCSSPrefix + 'grid-row-checker ' + Ext.baseCSSPrefix + 'grid-checkselect" role="presentation">&#160;</div>'
		else
			if record?.raw?._myProperties?.selectable is false
				return '<div class="' + Ext.baseCSSPrefix + 'grid-row-checker selectmodel-item-disabled" role="presentation">&#160;</div>'
			else
				return '<div class="' + Ext.baseCSSPrefix + 'grid-row-checker" role="presentation">&#160;</div>'

	getHeaderConfig: ->
		config = @callParent arguments
		return config if not @buffered
		gridProps = @getGridProps true
		selColConfig =
			xtype: 'coreselectcolumn'
			width: 32
			menuDisabled: false
			selectedAll: gridProps.selectedAll
			selectAllScope: gridProps.selectAllScope
		Ext.apply config, selColConfig
		return config