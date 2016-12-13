# This tools is for Selenium operating components
Ext.define 'Corefw.util.SeleniumTestTool',
	singleton: true

	Combobox:
		selectByText: (combobox, value)->
			displayField = combobox.displayField
			items = combobox.store.data.items
			[record] = items.filter (r)->
				return true if (r.data[displayField] is value)
			return unless record
			index = record.index or items.indexOf record
			[itemDom] = Ext.DomQuery.select ".x-boundlist:visible li:nth(#{index + 1})"
			return itemDom

	RadioGroup:
		selectByText: (radioGroup, value)->
			return unless radioGroup
			[radio] = radioGroup.items.items.filter (r)->
				return true if r.boxLabel is value
			[dom] = Ext.DomQuery.select 'input', radio.el.dom
			return dom

	CheckGroup:
		selectByText: (checkGroup, value)->
			return unless checkGroup
			[check] = checkGroup.items.items.filter (r)->
				return true if r.boxLabel is value
			[dom] = Ext.DomQuery.select 'input', check.el.dom
			return dom

		selectByIndex: (checkGroup, index)->
			return unless checkGroup
			check = checkGroup?.items?.items[index]
			if check
				[dom] = Ext.DomQuery.select 'input', check.el.dom
				dom
			else
				null


	Grid:
		getCell: (header, rowIndex) ->
			grid = header.up 'grid'
			view = grid.getView()
			record = grid.store.getAt rowIndex
			cell = view.getCell record, header
			return cell

		getCellValue: (header, rowIndex)->
			cell = @getCell header, rowIndex
			return Ext.String.trim cell.el.dom.innerText

		isSelected: (component, rowIndex)->
			grid = component.grid
			selModel = grid.getSelectionModel()
			record = grid.store.getAt rowIndex
			return selModel.isSelected(record)

		isCheckBoxInColumnShown: (header, rowIndex)->
			cell = @getCell header, rowIndex
			return Ext.DomQuery.select('img', cell.dom).length > 0

	TreeGrid:
		isSelected: (component, rowIndex) ->
			selModel = component.tree.getSelectionModel()
			return selModel.isSelected(rowIndex)

		isLockedColumns: (header) ->
			return header.locked

		getNumberOfLockedColumns: (component) ->
			return component.tree.lockedGrid?.columns.length

		getEditingCell: (component, header) ->
			headerIndex = component.tree.columnManager.getHeaderIndex header
			numberOfLockedColumns = @getNumberOfLockedColumns component
			if numberOfLockedColumns
				if @isLockedColumns(header) is false
					headerIndex = headerIndex - @getNumberOfLockedColumns component
					if component.cache?._myProperties?.selectType isnt 'NONE'
						headerIndex = headerIndex - 1
					return component.tree.rowEditor.editor.items.items[1].items.items[headerIndex]
				else
					return component.tree.rowEditor.editor.items.items[0].items.items[headerIndex]
			else
				return component.tree.rowEditor.editor.items.items[headerIndex]

		clickHyperLinkInLockedView: (component, index) ->
			lv = component.up('coretreebase').getView().lockedView
			n = lv.getNodes()[index]
			r = lv.getRecord(n)
			d = lv.getCell(r, component)
			d.down('a').dom.click()
			return true

		getTreeCellValue: (header, rowIndex) ->
			component = header.up 'coretreegrid'
			numberOfLockedColumns = @getNumberOfLockedColumns component
			if numberOfLockedColumns
				if @isLockedColumns(header) is false
					view = component.down().getView().normalView
				else
					view = component.down().getView().lockedView
			else
				view = component.down().getView()
			node = view.getNodes()[rowIndex]
			record = view.getRecord(node)
			cell = view.getCell(record, header)
			return Ext.String.trim cell.el.dom.innerText

	TreePicker:
		selectByText: (value)->
			return unless value
			[pickerDom] = Ext.DomQuery.select '.x-window[id^=coretreepickerwindow]:visible'
			return unless pickerWindow
			id = pickerDom.id
			picker = Ext.getCmp id
			return unless picker
			tree = picker.down 'treepanel'
			root = tree.store.tree.root

	Menu:
		selectMenuItemByText: (value) ->
			menuItems = []
			menuWindow = Ext.DomQuery.select('.x-menu:last')[0]
			style = window.getComputedStyle(menuWindow)
			visibility = style?.getPropertyValue('visibility')
			# should use Ext.getCmp(menuWindow.id).hidden	, but current menu cannot prepare in js unit test, we use blow condition statement
			if visibility != 'hidden'
				menuItems = Ext.DomQuery.select '.x-menu-item-text', menuWindow

			for menuItem in menuItems
				if menuItem.innerHTML == value
					return menuItem
			return

	MonthPicker:
		pickMonthByValue: (value) ->
			ym = value.split("-")
			monthLinks = Ext.DomQuery.select(".x-monthpicker-months div a")
			for monthLink in monthLinks
				if monthLink.innerText == Ext.Date.getShortMonthName(parseInt(ym[1] - 1))
					monthLink.click()

			yearLinks = Ext.DomQuery.select(".x-monthpicker-years div a")

			for yearLink in yearLinks
				if yearLink.innerText == ym[0]
					yearLink.click()

			return Ext.DomQuery.select(".x-monthpicker-buttons a")[0]

	Chart:
		getSerieToolTipValue: (corechart, serieType, groupBy, index) ->
			chart = Ext.ComponentQuery.query('.chart', corechart)[0]
			for item in chart.series.items
				if item.type is serieType and item.xField is groupBy
					serie = item
					break
			if serie
				serieItem = serie.items[index]
				serie.showTip serieItem
				spans = Ext.DomQuery.select('span', serie.tooltip.el.dom)
				spansInnerText = []
				for span in spans
					spansInnerText.push span.innerText
				return spansInnerText.join('|')
			return ''