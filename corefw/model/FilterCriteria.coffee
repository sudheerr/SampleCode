Ext.define 'Corefw.model.FilterCriteria',
	extend: 'Ext.data.Model'
	alternateClassName: "CorefwFilterModel"
	requires: [ 'Corefw.util.Formatter' ]
	fields: [
		{
			name: 'pathString'
			type: 'string'
		}
		{
			name: 'operator'
			type: 'string'
		}
		{
			name: 'dataTypeString'
			type: 'string'
		}
		{
			name: 'operandsString'
			type: 'auto'
		}
		{
			name: 'measure'
			type: 'boolean'
			defaultValue: false
		}
		{
			name: 'isForHistoricalColumn'
			type: 'boolean'
			defaultValue: false
		}
		{
			name: 'isForAggregatedColumn'
			type: 'boolean'
			defaultValue: false
		}
		{
			name: 'aggregationMeasure'
			type: 'string'
			useNull: true
		}
		{
			name: 'histColumnHeaderName'
			type: 'string'
			useNull: true
		}
		{
			name: 'compareTimeoffset'
			type: 'string'
			useNull: true
		}
		{
			name: 'compareMeasureName'
			type: 'string'
			useNull: true
		}
		{
			name: 'disabled'
			type: 'boolean'
			defaultValue: true
		}
		{
			name: 'isNegated'
			type: 'boolean'
			defaultValue: false
		}
		{
			name: 'elementAggregationColumnNotExisted'
			type: 'boolean'
			defaultValue: false
		}
		{
			name: 'elementComparisonColumnNotExisted'
			type: 'boolean'
			defaultValue: false
		}
		{
			name: 'repetitiveRatio'
			type: 'int'
			defaultValue: -1
		}
		{
			name: 'relativeCompareTimeOffset'
			type: 'string'
			defaultValue: ''
		}
		{
			name: 'itemName'
			type: 'string'
			defaultValue: ''
		}
		{
			name: 'compareMeasureString'
			type: 'string'
			defaultValue: ''
		}
	]

	idProperty: 'pathString'

	copyFrom: (record, keyMapping={}, keys=null)->
		@fields.each (field)->
			key = field.name
			return if keys and not Ext.Array.contains(keys, key)
			targetKey = if keyMapping[key] then keyMapping[key] else key
			@set key, record.get(targetKey) if record.get(targetKey)
		, this

	setChildren: (recds) ->
		@children = [].concat recds
		return

	getChildren: (recds) ->
		@children

	removeChildrenByCondition: (fn) ->
		left = []
		children = @children
		i = 0
		l = children.length
		while i < l
			flag = fn(children[i])
			if not flag
				left.push children[i]
			i++
		@children = left
		return

	removeChildren: (recds) ->
		left = []
		children = @children
		i = 0
		l = children.length
		while i < l
			if recds.indexOf(children[i]) is -1
				left.push children[i]
			i++
		@children = left
		return

	equals: (record) ->
		if this is record
			return true
		if not record
			return false
		if not (record instanceof Corefw.model.FilterCriteria)
			return false
		if not @get 'pathString'
			if record.get 'pathString'
				return false
		else if @get('pathString') isnt record.get('pathString')
			return false
		if not @get 'operator'
			if record.get 'operator'
				return false
		else if @get('operator') isnt record.get('operator')
			return false
		if not @get 'operandsString'
			if record.get 'operandsString'
				return false
		else if not record.get 'operandsString'
			return false
		else if @get('operandsString').length isnt record.get('operandsString').length
			return false
		else
			i = 0
			while i < @get('operandsString').length
				if @get('operandsString')[i] isnt record.get('operandsString')[i]
					return false
				i++
		true

	statics:
		HISTORICAL_COLUMN_IDENTIFICATION_STRING: "compareWith"
		COMPARE_MEASURE_NAME_IDENTIFICATION_STRING: "by"

		OPERATOR_MAP:
			'eq': '='
			'ne': 'isnt'
			'lt': '<'
			'le': '<='
			'gt': '>'
			'ge': '>='
			'like': 'Like'
			'notLike': 'Not Like'
			'likeObjectString': 'Like'
			'between': 'Between'
			'in': 'In'
			'notIn': 'Not In'
			'existsAny': 'Exists Any'
			'existsAll': 'Exists All'
			'isNull': 'Is Null'
			'isNotNull': 'Is Not Null'
			'isNullOrEmpty': 'Is Null or Empty'
			'isNotNullOrEmpty': 'Is Not Null or Empty'

		operandNumber: (operator)->
			if Ext.Array.contains ["isNull", "isNotNull", "isNullOrEmpty", "isNotNullOrEmpty"], operator
				return 0
			return -1

		fiscalRegex: new RegExp("D:TimeMark-I:", "")

		setAggregationOrCompareInfo: (newOrUpdatedCriterion, triggerOwner) ->
			if triggerOwner
				if triggerOwner instanceof Ext.grid.column.Column
					@setAggregationOrCompareInfoByColumn newOrUpdatedCriterion, triggerOwner
				else if triggerOwner instanceof Corefw.model.FilterCriteria
					@setAggregationOrCompareInfoByModelInstance newOrUpdatedCriterion, triggerOwner.data
			return

		setAggregationOrCompareInfoByColumn: (newOrUpdatedCriterion, columnInfo) ->
			if not columnInfo
				return
			headerName = columnInfo.T
			if @isHistoricalColumn(columnInfo)
				newOrUpdatedCriterion.isForHistoricalColumn = true
				newOrUpdatedCriterion.histColumnHeaderName = headerName
				newOrUpdatedCriterion.compareTimeoffset = @getCompareTimeoffset(columnInfo.dataIndex)
				newOrUpdatedCriterion.compareMeasureName = @getCompareMesureName(columnInfo.dataIndex)
				newOrUpdatedCriterion.compareMeasureString = columnInfo.compareMeasureString
			else
				newOrUpdatedCriterion.isForHistoricalColumn = false
				newOrUpdatedCriterion.histColumnHeaderName = null
				newOrUpdatedCriterion.compareTimeoffset = null
				newOrUpdatedCriterion.compareMeasureName = null
				newOrUpdatedCriterion.compareMeasureString = null
			if @isAggregatedColumn(columnInfo)
				newOrUpdatedCriterion.isForAggregatedColumn = true
				newOrUpdatedCriterion.aggregationMeasure = columnInfo.aggregateMeasureString
			else
				newOrUpdatedCriterion.isForAggregatedColumn = false
				newOrUpdatedCriterion.aggregationMeasure = ''
			return

		setAggregationOrCompareInfoByModelInstance: (newOrUpdatedCriterion, data) ->
			if not newOrUpdatedCriterion or not data
				return
			Ext.applyIf newOrUpdatedCriterion, data
			return

		getCompareMesureName: (dataIndex) ->
			self = Corefw.model.FilterCriteria
			if not dataIndex or dataIndex.length is 0
				return null
			compareMeasureName = null
			if dataIndex.indexOf(self.HISTORICAL_COLUMN_IDENTIFICATION_STRING) > -1
				splits = dataIndex.split(self.COMPARE_MEASURE_NAME_IDENTIFICATION_STRING)
				if splits[1]
					compareMeasureName = Ext.String.trim(splits[1])
			if not compareMeasureName
				return null
			compareMeasureName

		getCompareTimeoffsetByTimeLabel: (headerName) ->
			if headerName
				start = headerName.indexOf('(')
				end = headerName.indexOf(')')
				return headerName.substring(start + 1, end).replace('-', '_')
			''

		getCompareTimeoffset: (pathString) ->
			if not pathString or pathString.length is 0
				return null
			regex = new RegExp('compareWith\\s([\\w~]+)*\\sby', 'i')
			tmp = regex.exec(pathString)
			parts = []
			if tmp
				return tmp[1]
			null

		isHistoricalColumn: (columnInfo) ->
			self = Corefw.model.FilterCriteria
			if not columnInfo
				return false
			dataIndex = columnInfo.dataIndex
			if not dataIndex or dataIndex.length is 0
				return false
			if dataIndex.indexOf(self.HISTORICAL_COLUMN_IDENTIFICATION_STRING) isnt -1
				return true
			false

		isAggregatedColumn: (columnInfo) ->
			if not columnInfo
				return false
			aggregateMeasureString = columnInfo.aggregateMeasureString
			if not aggregateMeasureString or aggregateMeasureString.length is 0
				return false
			else
				return true
			false

		isTwoCriteriaFilterFieldSame: (criterion1, criterion2) ->

			transformStrVal = (val)-> if val is 'null' then null else val
			equals = (val1, val2) ->
				val1 = transformStrVal val1
				val2 = transformStrVal val2
				(not val1 and not val2) or val1 isnt val2

			if criterion1.pathString is criterion2.pathString
				return equals(criterion1.aggregationMeasure, criterion2.aggregationMeasure) and
					equals(criterion1.compareMeasureName, criterion2.compareMeasureName)
			false

		addOperands: (operands, isTimeMark, columnDate, criObj) ->
			p = new RegExp('~M')
			ops = ''
			Ext.each operands, (operand) ->
				if columnDate
					dataList = operand.split('-')
					dateString = dataList[0] + '-' + dataList[1] + (if dataList[2] is 0 then '' else '-' + dataList[2])
					operand = CorefwFormatter.formatDate(dateString, if dataList[2] is 0 then 'ForDisplayM' else 'ForDisplayD')
				else if criObj.dataTypeString is 'float'
					operand = CorefwFormatter.formatDouble operand
				else if criObj.dataTypeString is 'int'
					operand = CorefwFormatter.formatInt operand
				if operand is ''
					operand = '""'
				if ops is ''
					ops = operand
				else
					ops = ops + ' ; ' + operand
				return
			return ops

		getCriteriaLabel: (criObj, isInlineFilter) ->
			self = Corefw.model.FilterCriteria
			displayName = if criObj.itemName then criObj.itemName else criObj.pathString.split(':').pop()
			displayNameList = displayName.split ' '
			descMap = self.OPERATOR_MAP
			if displayNameList.length > 1 and displayNameList[displayNameList.length - 1].substr(displayNameList[displayNameList.length - 1].length - 1, 1) is ']'
				return displayName
			ops = ''
			operands = criObj.operandsString
			operator = criObj.operator
			retValue = undefined
			isTimeMark = false
			columnDate = false
			dt = false
			innerCriObj = undefined
			innera = []
			innerDisplayName = undefined
			innerOperator = undefined
			innerOperands = []
			innerOps = ''
			if operator isnt 'existsAny' and operator isnt 'existsAll'
				if self.fiscalRegex.test criObj.pathString
					isTimeMark = true
				else if criObj.dataTypeString is 'date'
					columnDate = true
				if criObj.isForHistoricalColumn
					displayName = criObj.histColumnHeaderName
				aggreMeasureName = criObj.aggregationMeasure
				if criObj.isForAggregatedColumn and aggreMeasureName
					name = aggreMeasureName.split('-')[0]
					if name
						name = name[0].toLowerCase() + name.substr(1, name.length - 1)
						displayName = displayName + name.sub()
				ops = self.addOperands operands, isTimeMark, columnDate, criObj
			else
				innerCriObj = operands[0]
				innerOperands = innerCriObj.operandsString
				innera = innerCriObj.pathString.split(':')
				innerDisplayName = innera[innera.length - 1]
				innerOperator = innerCriObj.operator
				ops = innerDisplayName + ' ' + descMap[innerOperator]
				innerOps = self.addOperands innerOperands, isTimeMark, columnDate, innerCriObj
				ops = ops + ' [' + innerOps + ']'
			if isInlineFilter
				retValue = descMap[operator]
			else
				retValue = displayName + ' ' + descMap[operator]
			if self.operandNumber(criObj.operator) isnt 0
				retValue = retValue + ' [' + ops + ']'
			return [retValue, ops]

		validateCriteritionOperand: (inputValue, operator)->
			separator = "\u2502"
			if inputValue isnt undefined and inputValue isnt null and inputValue isnt ''
				if inputValue.indexOf(';') > -1 or inputValue.indexOf('~') > -1
					Corefw.Msg.alert 'Alert', "Please enter a valid value except ';~'!"
					return false
				if inputValue.indexOf(separator) > -1
					Corefw.Msg.alert 'Alert', "Please enter a valid value except '" + separator + ";~'!"
					return false
				if (operator is 'like' or operator is 'notLike') and /[*]{2,}/.test(inputValue)
					Corefw.Msg.alert 'Alert', "Consecutive * is unnecessary and not allowed!"
					return false
			else
				Corefw.Msg.alert 'Alert', 'Please enter a valid value.'
				return false
			return true