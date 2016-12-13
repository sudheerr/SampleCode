Ext.define 'Corefw.view.component.SimpleList',
	extend: 'Ext.panel.Panel'
	alias: 'widget.simpleList'
	autoScroll: true
	layout: 'vbox'
	componentCls: 'simpleList'
	initSize: null
	maxSize: null
	itemHeight: 34
	initComponent: ->
		@callParent arguments
		if @initSize != null
			@height = @itemHeight * @initSize
	removeAll: ->
		@callParent arguments
		if @initSize != null
			@setHeight @initSize * @itemHeight
	getSize: ->
		@query('field').length
	addItem: (value) ->
		itemCnt = @getSize()
		if @maxSize isnt null and itemCnt < @maxSize
			@setHeight @itemHeight * (itemCnt + 1)
		item = 
			xtype: 'toolbar'
			width: '100%'
			padding: '2 0 2 0'
			layout: 'hbox'
			items: [
				{
					xtype: 'button'
					text: ''
					cls: 'deleteIcon'
					width: 28
					listeners: click: ->
						@up('panel').remove @up('toolbar').id
						return

				}
				{
					xtype: 'field'
					value: value
					flex: 1
				}
			]
		@add item
	removeLast: ->
		cnt = @getSize()
		if cnt
			@remove @query('toolbar')[cnt - 1]
	find: (value) ->
		@query('field').forEach (field, i) ->
			if field.getValue() == value
				return i
		-1
	getItems: ->
		@query('field').map (field) ->
			field.getValue()