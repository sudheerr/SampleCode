Ext.define 'Corefw.view.filter.menu.TimeMark',
	extend: 'Corefw.view.component.MenuWin'
	alias: 'widget.filterMenuTimeMark'
	requires: [
		'Corefw.util.Formatter'
		'Corefw.view.component.SelectableList'
	]
	plain: true
	cls: 'time_mark'
	config:
		filterPath: ''
		itemName: ''
		repetitiveRatio: -1
	getTimeMarkPath: ->
		samplePath = undefined
		if @menuRecord
			samplePath = @menuRecord.getChildren()[0].get 'pathString'
		else if @filterPath
			samplePath = @filterPath
		if samplePath
			reg = /(.+D:TimeMark-I:).*/i
			result = reg.exec(samplePath)
			return if result then result[1] else null
		return
	style: 'z-index': '0'
	getBatchDataType: ->
		@down('[name=batchDataTypeBtngroup]').getBatchDataType()
	showBatchDataType: (cfg) ->
		cfg = cfg or {}
		btnGroup = @down('[name=batchDataTypeBtngroup]')
		batchFreGroup = @down('[name=batchFrequency]')
		if cfg.hasMonthly
			if !btnGroup.down('[batchDataType=monthly]')
				btnGroup.add
					boxLabel: 'Monthly'
					name: 'batchDataType'
					batchDataType: 'monthly'
					checked: true
		else
			btnGroup.remove btnGroup.down('[batchDataType=monthly]')
		if cfg.hasDaily
			if !btnGroup.down('[batchDataType=daily]')
				btnGroup.add
					boxLabel: 'Daily'
					name: 'batchDataType'
					batchDataType: 'daily'
					checked: true
		else
			btnGroup.remove btnGroup.down('[batchDataType=daily]')
		return
	items: [
		{
			xtype: 'checkbox'
			height: 22
			name: 'bestAvailable'
			boxLabel: 'Best Available'
			getDDIName: ->
				'Is BestAvailable'
			getOprandString: ->
				true
			handler: (me, newVal) ->
				if newVal
					warnMsg = 'Best Available does not support variance column(s):'
					hasVariance = false
					num = 1
					Ext.ComponentQuery.query('tableelement gridcolumn').forEach (e, i) ->
						if e['compareMeasureString']
							warnMsg += '<br/>' + num++ + ': ' + e['text']
							hasVariance = true
						return
					if hasVariance
						Corefw.Msg.alert 'Alert', warnMsg
						@setValue false
						return
				menu = @up 'menu'
				menu.down('[name=batchDataTypeBtngroup]').setDisabled newVal
				menu.down('[name=fiscalDateView]').setDisabled newVal
				menu.down('[name=operationCombo]').setDisabled newVal
				btnGroup = menu.down('[name=batchDataTypeBtngroup]')
				batchFreGroup = menu.down('[name=batchFrequency]')
				if newVal
					btnGroup.hide()
					batchFreGroup.show()
				else
					batchFreGroup.hide()
					btnGroup.show()
				return
			setFieldValue: (val) ->
				if Ext.isArray(val)
					val = val[0]
				@setValue val
				return
		}
		{
			xtype: 'radiogroup'
			name: 'batchFrequency'
			width: 150
			items: [
				{
					boxLabel: 'Monthly'
					name: 'batchFrequency'
					frequency: 'Monthly'
					checked: true
				}
				{
					boxLabel: 'Daily'
					name: 'batchFrequency'
					frequency: 'Daily'
					checked: false
				}
			]
			getDDIName: ->
				'Batch Frequency'
			getBatchFrequency: ->
				groupMembers = @query('radio')
				checkedValues = []
				i = 0
				len = groupMembers.length
				while i < len
					if groupMembers[i].getValue()
						return groupMembers[i].frequency
					i++
				return
			setFieldValue: (val) ->

				toSingleData = (val) ->
					if Ext.isArray(val)
						return toSingleData(val[0])
					val

				val = toSingleData(val)
				groupMembers = @query('radio')
				i = 0
				len = groupMembers.length
				while i < len
					if groupMembers[i].frequency == val
						groupMembers[i].setValue true
					i++
				return
		}
		{
			xtype: 'checkboxgroup'
			name: 'batchDataTypeBtngroup'
			width: 150
			getBatchDataType: ->
				groupMembers = @query('checkbox')
				checkedValues = []
				i = 0
				len = groupMembers.length
				while i < len
					if groupMembers[i].getValue()
						checkedValues.push groupMembers[i].batchDataType
					i++
				checkedValues
			defaults: handler: (me, checked) ->
				@up('filterMenuTimeMark').changeBatchDataType()
				return
			items: []
		}
		{
			xtype: 'combo'
			name: 'operationCombo'
			queryMode: 'local'
			displayField: 'desc'
			editable: false
			selectOnFocus: false
			hideLabel: true
			valueField: 'operation'
			value: 'in'
			store: Ext.create('Ext.data.Store',
				fields: [
					'operation'
					'desc'
				]
				data: [
					{
						'operation': 'in'
						'desc': 'In'
					}
					{
						'operation': 'ni'
						'desc': 'Not In'
					}
				])
		}
		{
			xtype: 'selectableList'
			name: 'fiscalDateView'
			getDDIName: ->
				'TimeMark Key'
			labelRender: (v, me) ->
				return CorefwFormatter.formatRelativeDate v.text
		}
	]
	listeners:
		beforeshow: (m, eOp) ->
			itemName = m.getItemName()
			dtFisVw = m.down '[name=fiscalDateView]'
			if itemName
				m.setTitle itemName
			else
				a = m.filterPath.split ':'
				m.setTitle a[a.length - 1]
			menuRecord = m.menuRecord
			dtFisVw.getStore().pathString = m.getTimeMarkPath() + dtFisVw.getDDIName()
			dtFisVw.store.load ->
				hasDaily = dtFisVw.store.findByTypes(["Daily"]) > -1
				hasMonthly = dtFisVw.store.findByTypes(["Monthly"]) > -1
				m.showBatchDataType hasMonthly: hasMonthly, hasDaily: hasDaily
				
				batchTypes = m.getBatchDataType()
				dtFisVw.store.filterData batchTypes

				dtFisVw.refresh()
				dtFisVw.show()
				if m.down('[name=bestAvailable]').getValue()
					dtFisVw.setDisabled true
					m.down('[name=batchDataTypeBtngroup]').hide()
					m.down('[name=batchFrequency]').show()
				else
					m.down('[name=batchDataTypeBtngroup]').show()
					m.down('[name=batchFrequency]').hide()
				return
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
			width: 55
			cls: 'primaryBtn'
			handler: (button, e) ->
				menu = button.up 'menu'
				pathPreix = menu.getTimeMarkPath()
				criteriaStore = button.up('filterMenuTimeMark').criteriaStore
				dtFisVw = menu.down '[name=fiscalDateView]'
				comb2 = menu.down 'combo'
				triggerOwner = menu.triggerOwner
				criteriaStore.clearTimeMarkCriteria()
				if menu.down('[name=bestAvailable]').getValue()
					bestbestAvailable = menu.down '[name=bestAvailable]'
					batchFrequency = menu.down '[name=batchFrequency]'
					criObj1 = 
						measure: false
						dataTypeString: 'boolean'
						disabled: false
						pathString: pathPreix + bestbestAvailable.getDDIName()
						operator: 'eq'
						itemName: bestbestAvailable.getDDIName()
						operandsString: [ true ]
					criObj2 = 
						measure: false
						dataTypeString: 'string'
						disabled: false
						pathString: pathPreix + batchFrequency.getDDIName()
						operator: 'eq'
						itemName: batchFrequency.getDDIName()
						operandsString: [ batchFrequency.getBatchFrequency() ]
					criteriaStore.loadData [
						criObj1
						criObj2
					], true
					menu.setVisible false
					return
				
				inputValue = []
				Ext.Array.each dtFisVw.checkboxes, (r) ->
					inputValue.push r.inputValue if r.getValue()
					return		
				criObj = {}
				criObj.measure = false
				criObj.pathString = pathPreix + dtFisVw.getDDIName()
				criObj.itemName = criteriaStore.getTimeMarkKeyItemName()
				criObj.operandsString = []
				criObj.dataTypeString = 'date'
				criObj.disabled = false
				if not (inputValue and inputValue.length > 0)
					Corefw.Msg.alert 'Alert', 'Please choose a value.'
					return
				else
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
			handler: (button, e) ->
				menu = button.up('menu')
				menu.setVisible false
				return
		}
	]
	setFilterMenuComboStore: (menu, pathString, extraParams) ->
		menu.pathString = pathString
		if extraParams
			Ext.apply @down('[name=fiscalDateView]').getStore().getProxy().extraParams, extraParams
		return
	changeBatchDataType: ->
		@down('[name=fiscalDateView]').filterBatchData @getBatchDataType()
		return
	clearMenu: ->
		@down('combobox').select 'in'
		delete @menuRecord
		return
	setRecord: (record) ->
		@menuRecord = record
		return
	isOprandIn: (oprand) ->
		if !@menuRecord
			return false
		allRecs = @menuRecord.getChildren()
		i = 0
		l = allRecs.length
		while i < l
			if allRecs[i].get('operandsString').indexOf(oprand) > -1
				return true
			i++
		false
	changeMenuFilterValue: (filterRecord) ->
		menu = this
		if filterRecord and filterRecord.data
			filterData = filterRecord.data
			opCombo = menu.down 'combo[name=operationCombo]'
			allRecds = filterRecord.getChildren()
			cmps = [
				menu.down('[name=bestAvailable]')
				menu.down('[name=batchFrequency]')
			]
			for record in allRecds
				if record.get('pathString').indexOf('I:TimeMark Key') > -1
					operator = record.get('operator')
					if operator is 'eq'
						operator = 'in'
					opCombo.select operator
					operandList = record.get 'operandsString'
				else
					j = 0
					_l = cmps.length
					while j < _l
						if record.get('pathString').indexOf(cmps[j].getDDIName()) > -1
							cmps[j].setFieldValue record.get('operandsString')
						j++
		return