Ext.define 'Corefw.view.filter.menu.Date',
	extend: 'Corefw.view.component.MenuWin'
	alias: 'widget.filterMenuDate'
	plain: true
	config:
		filterPath: ''
		itemName: ''
		repetitiveRatio: -1
	style:
		'z-index': '0'
	items: [
		{
			xtype: 'combo'
			name: 'operationCombo'
			queryMode: 'local'
			displayField: 'desc'
			editable: false
			selectOnFocus: false
			hideLabel: true
			valueField: 'operation'
			value: 'eq'
			loadStoreForDate: ->
				@getStore().loadData [
					{
						'operation': 'eq'
						'desc': 'Equals'
					}
					{
						'operation': 'ne'
						'desc': 'Not Equals'
					}
					{
						'operation': 'gt'
						'desc': 'After'
					}
					{
						'operation': 'lt'
						'desc': 'Before'
					}
					{
						'operation': 'between'
						'desc': 'Between'
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
				return
			store: Ext.create('Ext.data.Store',
				fields: [
					'operation'
					'desc'
				]
				data: [ {
					'operation': 'eq'
					'desc': 'Equals'
				} ])
			operandCnt: (operator) ->
				cnt = 1
				if operator is 'in' or operator is 'notIn'
					cnt = 3
				else if operator is 'between'
					cnt = 2
				cnt
			isSingleOperationValue: ->
				singleAddOprands = [
					'eq'
					'ne'
					'gt'
					'lt'
				]
				singleAddOprands.indexOf(@getValue()) > -1
			listeners: change: (combo, newValue, oldValue) ->
				dateView = combo.up('menu').down('[name=dateSelectionView]')
				if combo.operandCnt(newValue) isnt combo.operandCnt(oldValue)
					dateView.removeAll()
				return
		}
		{
			xtype: 'datepicker'
			showToday: false
			height: 'auto'
			handler: (picker, date) ->
				dateView = picker.up('menu').down('[name=dateSelectionView]')
				str = Ext.Date.format(date, 'Y-n-j-H-i-s')
				if @up('filterMenuDate').down('[name=operationCombo]').isSingleOperationValue()
					dateView.removeAll()
					dateView.addItem str
				else if @up('filterMenuDate').down('[name=operationCombo]').getValue() is 'between'
					if dateView.getSize() >= 2
						dateView.removeLast()
					dateView.addItem str
				else
					if dateView.find(str) is -1
						dateView.addItem str
				return
		}
		{
			xtype: 'simpleList'
			name: 'dateSelectionView'
			initSize: 0
			maxSize: 3
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
			dtSelVw = m.down('[name=dateSelectionView]')
			dp = m.down('datepicker')
			if itemName
				m.setTitle itemName
			else
				a = m.filterPath.split(':')
				m.setTitle a[a.length - 1]
			dtSelVw.show()
			dp.show()
			m.down('combo').loadStoreForDate()
			if @menuRecord
				@changeMenuFilterValue @menuRecord
			return
		hide: ->
			@clearMenu()
			return
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
				path = menu.filterPath
				criObj = {}
				inputValue = []
				criteriaStore = button.up('filterMenuDate').criteriaStore
				dtSelView = menu.down '[name=dateSelectionView]'
				comb2 = menu.down 'combo'
				triggerOwner = menu.triggerOwner

				convert = (num) ->
					tmp = num.split('-')
					tmp[0] * 10000 + tmp[1] * 100 + Number(tmp[2])

				dtSelView.getItems().forEach (d) ->
					inputValue.push d
					return
				criObj.measure = false
				criObj.pathString = path
				criObj.itemName = menu.getItemName()
				criObj.operandsString = []
				criObj.dataTypeString = 'date'
				criObj.disabled = false
				if not (inputValue and inputValue.length > 0)
					Corefw.Msg.alert 'Alert', 'Please choose a value.'
					return
				else if comb2.getValue() is 'between' and inputValue.length isnt 2
					Corefw.Msg.alert 'Alert', 'Please choose two values when Between is selected.'
					return
				else
					if comb2.getValue() is 'between'
						inputValue.sort (x, y) ->
							if convert(x) > convert(y) then 1 else -1
					else if comb2.isSingleOperationValue() and inputValue.length > 1
						opValueChangMap = 
							'eq': 'in'
							'ne': 'notIn'
						newValue = opValueChangMap[comb2.getValue()]
						if newValue
							comb2.setValue newValue
					criObj.operandsString = inputValue
					criObj.replaceOps = true
					criObj.operator = comb2.getValue()
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
				menu = button.up('menu')
				menu.setVisible false
				return
		}
	]
	setFilterMenuComboStore: (menu, pathString, extraParams) ->
		menu.pathString = pathString
		return

	changeBatchDataType: ->
		@down('[name=fiscalDateView]').filterBatchData @getBatchDataType()
		return

	clearMenu: ->
		dtSelVw = @down('[name=dateSelectionView]')
		dtSelVw.removeAll()
		@down('combobox').select 'eq'
		delete @menuRecord
		return

	setRecord: (record) ->
		@menuRecord = record
		return

	isOprandIn: (oprand) ->
		if not @menuRecord
			return false
		@menuRecord.get('operandsString').indexOf(oprand) > -1
		
	changeMenuFilterValue: (filterRecord) ->
		menu = this
		dtSelVw = @down('[name=dateSelectionView]')
		if filterRecord and filterRecord.data
			filterData = filterRecord.data
			opCombo = menu.query('combo[name=operationCombo]')[0]
			opCombo.select filterRecord.get('operator')
			operandList = filterRecord.get('operandsString')
			Ext.Array.each operandList, (item) ->
				dtSelVw.addItem item.split('~D')[0].split('~M')[0]
				return
		return