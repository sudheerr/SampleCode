Ext.define 'Corefw.view.component.MenuWin',
	extend: 'Ext.menu.Menu'
	componentCls: 'menuWin'
	toolbarAlignment: null
	itemHeight: null
	itemVSpacing: null
	initComponent: (cfg) ->
		for item, index in @items
			if @itemHeight and not item.height
				item.height = @itemHeight
			if @itemVSpacing
				if index
					item.margin = '' + @itemVSpacing + ' 0 0 0'
				else
					item.margin = '0 0 0 0'
		if @toolbarAlignment is 'right'
			if @dockedItems and @dockedItems.length
				@dockedItems[0].items.unshift '->'
			if @bbar and @bbar.length
				@bbar.unshift '->'
		@callParent arguments
		return