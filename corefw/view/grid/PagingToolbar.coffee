Ext.define 'Corefw.view.grid.PagingToolbar',
	extend: 'Ext.toolbar.Paging'
	xtype: 'corepagingtoolbar'
	requires: ['Ext.form.field.ComboBox']

	beforePageSizeText: 'Show'
	afterPageSizeText: 'Items'
	pageSizeComboWidth: 50

	initComponent: ->
		@addListeners()
		@callParent arguments
		su = Corefw.util.Startup
		store = @store
		@pageSize = store.pageSize
		if su.getThemeVersion() is 2
			pageSizeField = @child('#pageMoreBtn')?.menu?.queryById('pageSize')
			if pageSizeField?
				pageSizeField.suspendEvents false
				pageSizeField.setValue store.pageSize
				pageSizeField.resumeEvents()
		else if store.selectablePageSizes
			psCombo = @down 'combobox#pagesize'
			if psCombo?
				psCombo.suspendEvents false
				psCombo.setValue store.pageSize
				psCombo.resumeEvents()
		return

	getPagingItems: ->
		me = @
		items = []
		su = Corefw.util.Startup
		items.push
			itemId: 'first'
			tooltip: me.firstText
			overflowText: me.firstText
			iconCls: "#{Ext.baseCSSPrefix}tbar-page-first"
			disabled: true
			handler: me.moveFirst
			scope: me
		if su.getThemeVersion() is 2
			@addCls('paginationcls')
			for index in items
				if index.itemId is 'first'
					index.iconCls = 'icon-jump-back'
					index.margin = '-2 2 0 0'
					index.style = 'color: #4CAEED;font-size:20px;width:20px'

		items.push
			itemId: 'prev'
			tooltip: me.prevText
			overflowText: me.prevText
			iconCls: "#{Ext.baseCSSPrefix}tbar-page-prev"
			disabled: true
			handler: me.movePrevious
			scope: me
		if su.getThemeVersion() is 2
			for index in items
				if index.itemId is 'prev'
					index.iconCls = 'icon-previous'
					index.margin = '-2 0 0 0'
					index.style = 'color: #4CAEED;font-size:20px'

		# set paging size list as a combo
		if su.getThemeVersion() isnt 2
			if me.store.selectablePageSizes
				items.push '-'
				items.push me.beforePageSizeText
				items.push
					xtype: 'combobox'
					itemId: 'pagesize'
					editable: false
					store: me.store.selectablePageSizes
					disabled: false
					width: me.pageSizeComboWidth
					scope: me
					listeners:
						scope: me
						change: me.reloadDataByPageSize
				items.push me.afterPageSizeText

		items.push '-'

		items.push me.beforePageText

		items.push
			xtype: 'numberfield'
			itemId: 'inputItem'
			name: 'inputItem'
			cls: "#{Ext.baseCSSPrefix}tbar-page-number"
			allowDecimals: false
			minValue: 1
			hideTrigger: true
			enableKeyEvents: true
			keyNavEnabled: false
			selectOnFocus: true
			submitValue: false
		# mark it as not a field so the form will not catch it when getting fields
			isFormField: false
			width: me.inputItemWidth
			margins: '-1 2 3 2'
			listeners:
				scope: me
				keydown: me.onPagingKeyDown
				blur: me.onPagingBlur

		items.push
			xtype: 'tbtext'
			itemId: 'afterTextItem'
			margin: '0 6 0 4' if su.getThemeVersion() is 2
			text: Ext.String.format me.afterPageText, 1

		items.push '-'

		items.push
			itemId: 'next'
			tooltip: me.nextText
			overflowText: me.nextText
			iconCls: "#{Ext.baseCSSPrefix}tbar-page-next"
			disabled: true
			handler: me.moveNext
			scope: me

		if su.getThemeVersion() is 2
			for index in items
				if index.itemId is 'next'
					index.iconCls = 'icon-next'
					index.margin = '-2 0 0 0'
					index.style = 'color: #4CAEED;font-size: 20px'

		items.push
			itemId: 'last'
			tooltip: me.lastText
			overflowText: me.lastText
			iconCls: "#{Ext.baseCSSPrefix}tbar-page-last"
			disabled: true
			handler: me.moveLast
			scope: me
		if su.getThemeVersion() is 2
			for index in items
				if index.itemId is 'last'
					index.iconCls = 'icon-jump-fwd'
					index.margin = '-2 4 0 3'
					index.style = 'color: #4CAEED;font-size: 20px;width: 20px'

		items.push '-'

		if su.getThemeVersion() isnt 2
			if not me.cache.hideRefresh
				items.push
					itemId: 'refresh'
					tooltip: me.refreshText
					overflowText: me.refreshText
					iconCls: "#{Ext.baseCSSPrefix}tbar-loading"
					handler: me.doRefresh
					scope: me

		if su.getThemeVersion() is 2
			menuItems = []
			beforePageSize =
				xtype: 'label'
				text: 'Show'
				margin: '0 6 0 0'
				cls: "#{Ext.baseCSSPrefix}tbar-page-menu-text"

			afterPageSize =
				xtype: 'label'
				text: 'Items'
				margin: '0 0 0 6'
				cls: "#{Ext.baseCSSPrefix}tbar-page-menu-text"

			menuItems.push beforePageSize
			menuItems.push
				xtype: 'numberfield'
				itemId: 'pageSize'
				cls: "#{Ext.baseCSSPrefix}tbar-page-size"
				width: 36
				height: 16
				disabled: false
				scope: me
				allowBlank: false
				allowDecimals: false
				msgTarget: 'none'
				minValue: 1
				hideTrigger: true
				enableKeyEvents: true
				keyNavEnabled: false
				selectOnFocus: true
				submitValue: false
				listeners:
					scope: me
					specialkey: (filed, e) ->
						me = @
						if e.getKey() is e.ENTER
							me.reloadDataByPageSize filed, filed.getValue()
							filed.up('menu').hide()
						return

			menuItems.push afterPageSize

			pageSizeCtn = Ext.create 'Ext.Container',
				itemId: 'pageSizeCtn'
				layout:
					type: 'hbox'
				items: menuItems

			pageNavCtn = Ext.create 'Ext.Container',
				itemId: 'pageNavCtn'
				layout:
					type: 'hbox'

			pageNavCtn.setVisible false

			pageInfoText =
				itemId: 'pageInfo'
				xtype: 'label'
				cls: "#{Ext.baseCSSPrefix}tbar-page-menu-text"

			menu = Ext.create 'Ext.menu.Menu',
				itemId: 'pageInfoMenu'
				bodyCls: "#{Ext.baseCSSPrefix}paging-more-menu"
				minWidth: 160
				shadow: false
				items: [pageNavCtn, pageSizeCtn, pageInfoText]

			btnMore = Ext.create 'Ext.Button',
				itemId: 'pageMoreBtn'
				tooltip: 'Show More'
				cls: "#{Ext.baseCSSPrefix}tbar-more"
				iconCls: "#{Ext.baseCSSPrefix}tbar-more-icon"
				margin: '-2 4 0 0'
				menu: menu
				scope: me
				listeners:
					click: (btn) ->
						btn.menu.showBy btn.up('header'), 'tr-br', [0, 1]

			items.push btnMore
		return items

# refresh the grid when page size changed
	reloadDataByPageSize: (comp, newPageSize, oldValue, eOpts) ->
		me = @

		rq = Corefw.util.Request
		fieldCt = me.up 'fieldcontainer'
		prop = fieldCt?.cache?._myProperties
		if prop.events['ONRETRIEVE']
			pagingEvent = prop.events['ONRETRIEVE']
		else
			pagingEvent = prop.events['ONLOAD']

		if pagingEvent?
			grid = me.ownerCt.ownerCt
			grid.store.pageSize = newPageSize
			me.doRefresh()
		return

	onRender: ->
		@callParent arguments
		su = Corefw.util.Startup
		me = @
		if su.getThemeVersion() is 2
			pagenum = me.getComponent('inputItem')
			pagenum.setHeight(16)
			pageData =
				currentPage: pagenum.value
			me.onPaginationChange(me, pageData)
		return

	addListeners: ->
		@listeners = @listeners or {}
		additionalListeners =
			change: @onPaginationChange
		Ext.apply @listeners, additionalListeners
		return

	onPaginationChange: (me, pageData = {}) ->
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			if pageData
				lastpagenum = me.totalPages
				currentPage = pageData.currentPage
				pageNavCtn = me.child('#pageMoreBtn').menu.child('#pageNavCtn')
				if pageNavCtn.items.items.length > 0
					me = pageNavCtn
				firstbtn = me.getComponent('first')
				prevbtn = me.getComponent('prev')
				lastbtn = me.getComponent('last')
				nextbtn = me.getComponent('next')
				aftertext = me.getComponent('afterTextItem')
				pagenumfield = me.getComponent('inputItem')
				if lastpagenum is 1 or lastpagenum is 0
					firstbtn.setVisible(false)
					prevbtn.setVisible(false)
					lastbtn.setVisible(false)
					nextbtn.setVisible(false)
				else
					if currentPage is 1
						firstbtn.setVisible(false)
						prevbtn.setVisible(false)
						lastbtn.setVisible(true)
						nextbtn.setVisible(true)
					else
						if currentPage is lastpagenum
							firstbtn.setVisible(true)
							prevbtn.setVisible(true)
							lastbtn.setVisible(false)
							nextbtn.setVisible(false)
						else
							firstbtn.setVisible(true)
							prevbtn.setVisible(true)
							lastbtn.setVisible(true)
							nextbtn.setVisible(true)

		return

# changing the currentPage number to thousand seperator format

	updateInfo: ->
		su = Corefw.util.Startup
		me = @

		displayItem = me.child '#displayItem'
		store = me.store
		pageData = me.getPageData()
		count = store.getCount()

		if su.getThemeVersion() is 2
			if pageData.total > 0
				me.setVisible true
			else
				me.setVisible false
			afterText = me.getComponent 'afterTextItem'
			if not afterText?
				afterText = me.child('#pageMoreBtn').menu.queryById('afterTextItem')
			totalPagesStr = afterText.text.slice 3
			totalPages = parseInt totalPagesStr, 10
			me.totalPages = totalPages
			afterText.setText('of ' + Ext.util.Format.number(totalPages, '0,000'))

		if count is 0
			msg = me.emptyMsg
		else
			msg = Ext.String.format me.displayMsg, pageData.fromRecord, pageData.toRecord, pageData.total
		if su.getThemeVersion() is 2
			pageInfo = me.child('#pageMoreBtn').menu.queryById('pageInfo')
			pageInfo.setText msg if pageInfo?
		else
			displayItem.setText msg if displayItem?
		return

	setChildDisabled: (selector, disabled) ->
		me = @
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			item = me.child(selector)
			if item? and not disabled
				item.removeCls "#{Ext.baseCSSPrefix}btn-default-toolbar-small-disabled"
		return me.callParent arguments

	child: (selector, returnDom) ->
		me = @
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			selectorList = ['#afterTextItem', '#first', '#prev', '#next', '#last', '#refresh', '#inputItem']
			if selectorList.indexOf selector >= 0
				selectorId = selector.replace '#', ''
				item = me.queryById selectorId
				return item
		return me.callParent arguments