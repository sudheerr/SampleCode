###
A Column definition class which renders a column for selection model providing enhanced support:
  - select scope can be change between page and grid
###

Ext.define 'Corefw.view.grid.column.SelectColumn',
	extend: 'Ext.grid.column.Column'
	alias: 'widget.coreselectcolumn'

	baseCls: Ext.baseCSSPrefix + 'coreselectcolumn-header'
	hoverCls: Ext.baseCSSPrefix + 'coreselectcolumn-header-over'

	selectAllScope: 'PAGE'
	prevsChecked: undefined

	# Below three functions are overriden to override the default menu behavior:
	#  - afterRender
	#  - onTitleMouseOver
	#  - onTitleMouseOut
	afterRender: ->
		@callParent arguments
		@titleEl.addCls @hoverCls

	onTitleMouseOver: ->

	onTitleMouseOut: ->

	onTitleElClick: (event, target)->
		me = this
		if target isnt me.triggerEl.el.dom
			@callParent arguments
			return

		if not me.menu
			me.menu = Ext.create 'Ext.menu.Menu',
				showSeparator: false,
				items: me.getMenuItems()
		me.menu.showBy event.target

	getMenuItems: ->
		me = this
		menuItems = [
			text: 'SelectAll scope:'
			cls: 'menusubtitle'
			plain: true
			isMenuItem: false
		,
			xtype: 'menucheckitem'
			text: 'Current page'
			group: 'gridSelectAllMode'
			handler: me.onSmPageClick
			scope: me
			checked: me.selectAllScope isnt 'GRID'
		,
			xtype: 'menucheckitem'
			text: 'Whole grid'
			group: 'gridSelectAllMode'
			handler: me.onSmGridClick
			scope: me
			checked: me.selectAllScope is 'GRID'
		]

	getGridProps: ->
		gridbase = @up 'coreobjectgrid'
		gridProps = gridbase?.grid.cache._myProperties
		return gridProps

	onSmPageClick: ->
		@selectAllScope = 'PAGE'
		@prevsChecked = undefined
		@up('coreobjectgrid').switchSelectAllScope()

	onSmGridClick: ->
		@selectAllScope = 'GRID'
		grid = @up 'coreobjectgrid'
		if grid.grid.getSelectionModel().getCount() is grid.grid.getStore().getCount()
			@getGridProps().selectedAll = true
		grid.switchSelectAllScope()

	generatePostData: ->
		me = this
		bufferedPostData = 
			selectedAll: @getGridProps().selectedAll
			selectAllScope: @selectAllScope
			deSelectingAll: @prevsChecked is true
		@prevsChecked = undefined
		return bufferedPostData

	updateState: (props) ->
		@selectAllScope = props.selectAllScope

	selectAllChange: (isCheckedPrevs) ->
		@prevsChecked = isCheckedPrevs