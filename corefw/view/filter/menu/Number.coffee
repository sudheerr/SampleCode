Ext.define 'Corefw.view.filter.menu.Number',
	extend: 'Corefw.view.component.MenuWin'
	alias: 'widget.filterMenuNumber'
	requires: [ 'Corefw.model.FilterCriteria' ]
	width: 180
	plain: true
	config:
		filterPath: ''
		itemName: ''
		repetitiveRatio: -1
	items: [
		{
			xtype: 'combo'
			name: 'operationCombo'
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
						'operation': 'lt'
						'desc': 'Less Than'
					}
					{
						'operation': 'le'
						'desc': 'Less Than Equal To'
					}
					{
						'operation': 'gt'
						'desc': 'Greater Than'
					}
					{
						'operation': 'ge'
						'desc': 'Greater Than Equal To'
					}
					{
						'operation': 'between'
						'desc': 'Between'
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
				]
			queryMode: 'local'
			displayField: 'desc'
			editable: false
			selectOnFocus: false
			hideLabel: true
			valueField: 'operation'
			listeners:
				afterrender: (combo) ->
					combo.setValue combo.getStore().getAt(0).get('operation')
					return
				change: (combo, records, eOpts) ->
					menu = combo.up('filterMenuNumber')
					if CorefwFilterModel.operandNumber(combo.getValue()) is 0
						menu.query('field[name=textFieldNormal]')[0].hide()
						menu.query('field[name=textFieldbetween]')[0].hide()
					else if combo.getValue() is 'between'
						menu.query('field[name=textFieldbetween]')[0].show()
						menu.query('field[name=textFieldNormal]')[0].show()
					else
						menu.query('field[name=textFieldbetween]')[0].hide()
						menu.query('field[name=textFieldNormal]')[0].show()
					return

		}
		{
			name: 'textFieldNormal'
			xtype: 'field'
			allowBlank: true
			value: ''
		}
		{
			name: 'textFieldbetween'
			xtype: 'field'
			allowBlank: true
			hidden: true
			value: ''
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
				menu = button.up('menu')
				opNumber = menu.query('combo[name=operationCombo]')[0].getValue()
				path = menu.filterPath
				criObj = {}
				temp = ''
				criteriaStore = button.up('filterMenuNumber').criteriaStore
				opTextField2 = menu.query('field[name=textFieldbetween]')[0]
				opTextField = menu.query('field[name=textFieldNormal]')[0]
				temp2 = ''
				triggerOwner = menu.triggerOwner
				criObj.pathString = path
				criObj.itemName = menu.getItemName()
				criObj.operator = opNumber
				criObj.operandsString = []
				criObj.disabled = false
				temp = opTextField.getValue()
				if CorefwFilterModel.operandNumber(criObj.operator) isnt 0
					getSpecailNum = (value) ->
						_value = (value + '').toUpperCase()
						specailNum = 
							'N/A': 'NaN'
							'+INFINITY': '+Infinity'
							'INFINITY': '+Infinity'
							'-INFINITY': '-Infinity'
						specailNum[_value]

					isSpecailNum = triggerOwner and triggerOwner.dataTypeString is 'float' and ! !getSpecailNum(opTextField.getValue())
					if isSpecailNum
						temp = getSpecailNum(temp)
					if temp is '' or !Ext.isNumeric(temp) and !isSpecailNum
						Corefw.Msg.alert 'Alert', 'Please enter a valid value.'
						opTextField.focus()
						return
					criObj.operandsString.push temp
					if criObj.operator is 'between'
						temp2 = opTextField2.getValue()
						isSpecailNum = triggerOwner and triggerOwner.dataTypeString is 'float' and ! !getSpecailNum(opTextField2.getValue())
						if isSpecailNum
							temp2 = getSpecailNum(temp2)
						if temp2 is '' or !Ext.isNumeric(temp2) and !isSpecailNum
							Corefw.Msg.alert 'Alert', 'Please enter a valid value.'
							opTextField2.focus()
							return
						criObj.operandsString.push temp2
				criObj.measure = true
				criObj.dataTypeString = menu.dataTypeString
				criObj.repetitiveRatio = menu.repetitiveRatio
				criteriaStore.addItemCriteriaStore criObj, triggerOwner
				menu.setVisible false
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
			return
		hide: ->
			@clearMenu()
			return
	setFilterMenuComboStore: ->
	clearMenu: ->
		@down('combo[name=operationCombo]').select 'eq'
		@down('field[name=textFieldNormal]').reset()
		@down('field[name=textFieldbetween]').reset()
		delete @menuRecord
		return
	setRecord: (record) ->
		@menuRecord = record
		return
	changeMenuFilterValue: (filterRecord) ->
		if filterRecord and filterRecord.data
			filterData = filterRecord.data
			textFieldNormal = @query('field[name=textFieldNormal]')[0]
			textFieldbetween = @query('field[name=textFieldbetween]')[0]
			opCombo = @query('combo[name=operationCombo]')[0]
			opCombo.select filterData.operator
			textFieldNormal.setValue filterData.operandsString[0]
			filterData.operator is 'between' and textFieldbetween.setValue(filterData.operandsString[1])
		return