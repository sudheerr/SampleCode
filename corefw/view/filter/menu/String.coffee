Ext.define 'Corefw.view.filter.menu.String',
	extend: 'Corefw.view.component.MenuWin'
	alias: 'widget.filterMenuString'
	requires: [
		'Corefw.view.component.TextLookup'
		'Corefw.model.FilterCriteria'
	]
	width: 190
	plain: true
	cls: 'filterMenuStringCls'
	config:
		filterPath: ''
		itemName: ''
		repetitiveRatio: -1
	title: ''
	items: [
		{
			xtype: 'combo'
			name: 'operationCombo'
			queryMode: 'local'
			displayField: 'desc'
			editable: false
			selectOnFocus: false
			hideLabel: true
			value: 'eq'
			valueField: 'operation'
			store: Ext.create 'Ext.data.Store',
				fields: [
					'operation'
					'desc'
				]
				data: [
					{
						'operation': 'eq'
						'desc': 'Equals'
					}
					{
						'operation': 'ne'
						'desc': 'Not Equals'
					}
					{
						'operation': 'like'
						'desc': 'Like'
					}
					{
						'operation': "notLike"
						'desc': 'Not Like'
					}
					{
						'operation': "isNull"
						'desc': 'IsNull'
					}
					{
						'operation': "isNotNull"
						'desc': 'IsNotNull'
					}
					{
						'operation': "isNullOrEmpty"
						'desc': 'IsNullOrEmpty'
					}
					{
						'operation': "isNotNullOrEmpty"
						'desc': 'IsNotNullOrEmpty'
					}
					{
						'operation': 'in'
						'desc': 'In'
					}
					{
						'operation': 'notIn'
						'desc': 'Not In'
					}
				]
			listeners: 
				change: (combo, records, eOpts) ->
					menu = combo.up 'filterMenuString'
					lookup = menu.down 'combo[name=comboTextNormal]'
					cb2 = menu.down 'toolbar[name=opToobarIn]'
					criteriaPanel = menu.down 'panel[name=criteriaPanel]'
					if combo.getValue() is 'in' or combo.getValue() is 'notIn'
						cb2.show()
						lookup.hide()
						criteriaPanel.show()
						Ext.Array.forEach menu.query('[name=allCriteria]'), (btn) ->
							btn.show()
							return
					else
						Ext.Array.forEach menu.query('[name=allCriteria]'), (btn) ->
							btn.hide()
							return
						cb2.hide()
						lookup.show()
						criteriaPanel.hide()
						lookup.reset()
						lookup.getStore().removeAll()
						if CorefwFilterModel.operandNumber(combo.getValue()) is 0
							lookup.hide()
							cb2.hide()
						else if combo.getValue() is 'like' or combo.getValue() is "notLike"
							Ext.apply lookup,
								queryMode: 'local'
								listConfig: emptyText: ''
						else
							Ext.apply lookup,
								queryMode: 'remote'
								listConfig: emptyText: 'No matching data found.'
					return
		}
		{
			name: 'comboTextNormal'
			xtype: 'textLookup'
		}
		{
			xtype: 'toolbar'
			layout: 'hbox'
			isFormField: true
			name: 'opToobarIn'
			cls: 'formField'
			hidden: true
			items: [
				{
					xtype: 'textLookup'
					name: 'comboTextIn'
					flex: 1
				}
				{
					xtype: 'button'
					text: ''
					cls: 'addIcon'
					height: 22
					border: 0
					handler: ->
						menu = @up 'menu'
						textinputField = menu.down 'combo[name=comboTextIn]'
						inputValue = textinputField.getValue()
						criteriaPanel = menu.down 'panel[name=criteriaPanel]'
						if Corefw.model.FilterCriteria.validateCriteritionOperand inputValue
							criteriaPanel.addItem inputValue
							textinputField.setValue ''
						return
				}
				{
					xtype: 'button'
					text: ''
					cls: 'importIcon'
					height: 22
					border: 0
					handler: ->
						menu = @up 'menu'
						uploadMenu = menu.createUploadMenu()
						uploadMenu.filterMenuId = menu.id
						uploadMenu.pageXY = [
							@getX() + 30
							@getY() - 3
						]
						uploadMenu.showOrHide()
						if uploadMenu.clickToggle
							criteria = menu.getFitlerValues()
							criteriaInpuArea = uploadMenu.down 'textareafield'
							criteriaInpuArea.setRawValue criteria
						return
				}
			]
		}
		{
			xtype: 'simpleList'
			name: 'criteriaPanel'
			hidden: true
			width: '100%'
			height: 185
			isFirstUpload: true
		}
	]
	bbar: [
		{
			xtype: 'button'
			scope: this
			text: 'Apply'
			cls: 'primaryBtn'
			width: 55
			listeners: render: (me) ->
				su = Corefw.util.Startup
				if su.getThemeVersion() is 2
					me.setUI 'primarybutton-small'
				return
			handler: (button, e) ->
				menu = button.up 'menu'
				path = menu.filterPath
				criObj = {}
				temp = ''
				temp2 = ''
				opMenuCombo = menu.down 'combo[name=comboTextNormal]'
				opComboBoxStr = menu.down 'combo[name=operationCombo]'
				opMenuCombo2 = menu.down 'combo[name=comboTextIn]'
				criteriaPanel = menu.down 'panel[name=criteriaPanel]'
				criteriaStore = button.up('filterMenuString').criteriaStore
				opString = opComboBoxStr.getValue()
				inputValue = opMenuCombo.getValue()
				triggerOwner = menu.triggerOwner
				criObj.pathString = path
				criObj.itemName = menu.getItemName()
				criObj.operator = opString
				criObj.operandsString = []
				criObj.disabled = false
				if criObj.operator is 'in' or criObj.operator is 'notIn'
					criteriaFields = criteriaPanel.query 'field'
					i = 0
					while i < criteriaFields.length
						item = criteriaFields[i]
						if item.xtype is 'field' and item.value isnt ''
							if not Corefw.model.FilterCriteria.validateCriteritionOperand item.value
								return
							criObj.operandsString.push item.value
						i++
					if criObj.operandsString.length < 2
						opMenuCombo2.onFocus()
						Corefw.Msg.alert 'Alert', 'Please add two values at least.'
						return
					menu.clearCurrentColumnPathOperands()
					Ext.Array.forEach criteriaPanel.query('field'), (item) ->
						if item.xtype is 'field' and item.value isnt ''
							menu.addCurrentColumnPathOperand item.value
						return
				else if criObj.operator isnt 'isNull' and criObj.operator isnt 'isNotNull' and criObj.operator isnt 'isNullOrEmpty' and criObj.operator isnt 'isNotNullOrEmpty'
					if not Corefw.model.FilterCriteria.validateCriteritionOperand inputValue, criObj.operator
						return
					temp = inputValue
					if criObj.operator is 'like' or criObj.operator is 'notLike'
						if not Ext.String.startsWith temp, '*'
							temp = '*' + temp
						if not Ext.String.endsWith temp, '*'
							temp = temp + '*'
					criObj.operandsString.push temp
				criObj.measure = false
				criObj.dataTypeString = menu.dataTypeString
				criObj.repetitiveRatio = menu.repetitiveRatio
				criObj.from = 'filterComobox'
				criteriaStore.addItemCriteriaStore criObj, triggerOwner
				menu.setVisible false
				return
		}
		{
			xtype: 'tbseparator'
			name: 'allCriteria'
			hidden: true
		}
		{
			xtype: 'button'
			name: 'allCriteria'
			text: 'Delete All'
			cls: 'primaryBtn'
			hidden: true
			listeners: render: (me) ->
				su = Corefw.util.Startup
				if su.getThemeVersion() is 2
					me.setUI 'primarybutton-small'
				return
			handler: (button, e) ->
				button.up('menu').down('panel[name=criteriaPanel]').removeAll()
				return
		}
		'-'
		{
			xtype: 'button'
			text: 'Cancel'
			cls: 'secondaryBtn'
			listeners: render: (me) ->
				su = Corefw.util.Startup
				if su.getThemeVersion() is 2
					me.setUI 'primarybutton-small'
				return
			handler: (button, e) ->
				button.up('menu').setVisible false
				return
		}
	]
	listeners:
		render: (me) ->
			su = Corefw.util.Startup
			if su.getThemeVersion() is 2
				me.setUI 'menupanelui'
			return
		beforeshow: (m, eOp) ->
			itemName = m.getItemName()
			if itemName
				m.setTitle itemName
			else
				a = m.filterPath.split(':')
				m.setTitle a[a.length - 1]
			if @menuRecord
				@changeMenuFilterValue @menuRecord
			@uploadMenu and (@uploadMenu.clickToggle = false)
			return
		beforehide: (m, eOp) ->
			@uploadMenu and @uploadMenu.hide()
			return
		hide: ->
			@clearMenu()
			return
	setFilterMenuComboStore: (menu, pathString, extraParams) ->
		for lookup in menu.query 'textLookup'
			lookupStore = lookup.getStore()
			lookupStore.pathString = pathString
			Ext.apply lookupStore.getProxy().extraParams, extraParams if extraParams
		return
	clearMenu: ->
		a = @down 'combo[name=operationCombo]'
		toRem = []
		a.select 'eq'
		Ext.Array.each @items.items, (item) ->
			if item.xtype is 'field'
				toRem.push item
			return
		Ext.Array.each toRem, (item) ->
			item.destroy()
			return
		lookup = @down 'combo[name=comboTextNormal]'
		lookup.reset()
		lookup.lastValue = 'CCQ'
		lookup.lastQuery = 'YXR'
		a = @down 'combo[name=comboTextIn]'
		a.reset()
		a.lastValue = 'CXA'
		a.lastQuery = 'YKX'

		###*delete items in criteriaPanel###

		@down('panel[name=criteriaPanel]').removeAll()
		delete @menuRecord
		return
	setRecord: (record) ->
		@menuRecord = record
		return
	createUploadMenu: ->
		if not @uploadMenu
			@uploadMenu = Ext.create 'Corefw.view.component.MenuWin',
				name: 'uploadMenu'
				title: 'Paste your criteria here (split the values by comma or newline)'
				width: 510
				margin: '0 0 10 0'
				floating: false
				renderTo: Ext.getBody()
				plain: true
				hidden: true
				clickToggle: false
				items: [ {
					xtype: 'textareafield'
					name: 'criteriaArea'
					height: 178
				} ]
				bbar: [
					{
						xtype: 'button'
						name: 'import'
						text: 'Create'
						width: 55
						cls: 'primaryBtn'
						handler: ->
							menu = @up('menu')
							textArea = @up('menu').down('textareafield')
							filterMenu = Ext.getCmp(menu.filterMenuId)
							filterMenu.createFilterCriteriaByText textArea.getValue()
							menu.clear()
							menu.showOrHide()
							return

					}
					'-'
					{
						xtype: 'button'
						text: 'Clear'
						width: 55
						cls: 'primaryBtn'
						handler: ->
							@up('menu').clear()
							return
					}
					'-'
					{
						xtype: 'button'
						text: 'Cancel'
						width: 55
						cls: 'secondaryBtn'
						handler: ->
							@up('menu').showOrHide()
							return
					}
				]
				showOrHide: ->
					if not @clickToggle
						@showAt @pageXY
						@el.setStyle 'z-index', '19999'
						@clickToggle = true
					else
						@hide()
						@clickToggle = false
					return
				clear: ->
					@down('textareafield').setValue ''
					return
		@uploadMenu
	createFilterCriteriaByText: (fileContent) ->
		menu = this
		criteriaList = fileContent.replace(/^,*|,*$/g, '').split('\n')
		criteriaPanel = menu.query('panel[name=criteriaPanel]')[0]
		cl = undefined
		criteriaPanel.removeAll()
		criteriaList.length is 0 and (criteriaList = fileContent.replace(/^,*|,*$/g, '').split(','))
		Ext.suspendLayouts()
		Ext.Array.forEach criteriaList, (c) ->
			if c is '' or typeof c is 'undefined'
				return
			cl = c.replace(/^,*|,*$/g, '').split(',')
			if cl.length > 0
				Ext.Array.forEach cl, (v) ->
					if v is '' or typeof v is 'undefined'
						return
					criteriaPanel.addItem v
					return
			else
				criteriaPanel.addItem v
			return
		Ext.resumeLayouts true
		return
	getFitlerValues: ->
		spliter = '\n'
		values = ''
		Ext.Array.forEach @query('panel[name=criteriaPanel] toolbar field'), (v) ->
			if values is ''
				values = v.getValue()
			else
				values = values + spliter + v.getValue()
			return
		values
	changeMenuFilterValue: (filterRecord) ->
		menu = this
		if filterRecord and filterRecord.data
			filterData = filterRecord.data
			normalTextField = menu.down 'combo[name=comboTextNormal]'
			opCombo = menu.down 'combo[name=operationCombo]'
			criteriaPanel = menu.down 'panel[name=criteriaPanel]'
			if filterData.operator is 'in' or filterData.operator is 'notIn'
				opCombo.select filterData.operator
				criteriaPanel.removeAll()
				Ext.suspendLayouts()
				Ext.Array.forEach filterData.operandsString, (filterValue) ->
					criteriaPanel.addItem filterValue
					return
				Ext.resumeLayouts true
			else
				opCombo.select filterData.operator
				normalTextField.setValue filterData.operandsString[0]
		return
	currentColumnPath: ''
	columnPathOperandsMap: {}
	getCurrentColumnOperands: ->
		me = this
		me.columnPathOperandsMap[me.currentColumnPath]
	setCurrentColumnPath: (pathString) ->
		me = this
		me.currentColumnPath = pathString
		if not me.columnPathOperandsMap[me.currentColumnPath]
			me.columnPathOperandsMap[me.currentColumnPath] = []
		return
	clearCurrentColumnPathOperands: ->
		me = this
		me.columnPathOperandsMap[me.currentColumnPath] = []
		return
	addCurrentColumnPathOperand: (operand) ->
		me = this
		me.getCurrentColumnOperands().push operand
		return