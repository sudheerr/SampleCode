Ext.define 'Corefw.store.FilterCriteria',
	extend: 'Ext.data.Store'
	model: 'Corefw.model.FilterCriteria'
	isGlobal: false
	config:
		timeMarkKeyItemName: ''
	addToStore: (criObj) ->
		s = this
		rec = s.find('pathString', criObj.pathString)
		if rec > -1
			Corefw.Msg.alert 'Alert', criObj.displayName + ' already exists.'
			return 0
		else
			s.add criObj
			return 1

	fetchTimeMarkDisplayString: (timeMarkDDIs) ->
		timeMarkDDIs = [].concat(timeMarkDDIs)
		ret = []
		ret.push d.get('operandsString') for d in timeMarkDDIs
		return ret

	fetchTimeMarkItemName: (timeMarkDDIs) ->
		timeMarkDDIs = [].concat(timeMarkDDIs)
		itemName = ''
		i = 0
		len = timeMarkDDIs.length
		while i < len
			itemName = timeMarkDDIs[i].get('itemName')
			if itemName
				return itemName
			i++
		return

	loadRecords: (records, options) ->
		addRecords = false
		timeMarkRed = null
		newRecds = []
		if options
			addRecords = options.addRecords
		timeMarks = []
		for record in records
			if @isTimeMarkCriteriaPath record.get('pathString')
				timeMarks.push record
				if record.get('pathString').indexOf 'TimeMark Key' > -1
					@setTimeMarkKeyItemName record.get('itemName')
			else
				newRecds.push record
		if timeMarks.length
			rawData = 
				pathString: 'TIME MARK'
				itemName: ''
				operator: ''
				disabled: false
				dataTypeString: ''
			timeMarkRed = @createModel rawData
			timeMarkRed.setChildren timeMarks
			newRecds.unshift timeMarkRed
		@callParent [
			newRecds
			options
		]
		return

	getCriObjByPath: (path) ->
		ret = null
		@each (record) ->
			_path = record.get 'pathString'
			ret = record
			if _path is path
				return false
			return
		if ret
			return @getCriteriaFromRecord ret
		return

	isTimeMarkCriteriaPath: (path) ->
		if path
			return path.indexOf('D:TimeMark-I:') > -1
		return false

	clearTimeMarkCriteria: ->
		me = this
		@filterBy (record) ->
			not me.isTimeMarkPath record.get('pathString')
		return

	isTimeMarkPath: (path) ->
		return path is 'TIME MARK'

	listeners:
		remove: (store, record, index, isMove, eOpts) ->
			store.saveCriteriaIntoSession store
			return
		datachanged: (store, eOpts) ->
			store.saveCriteriaIntoSession store
			return
		load: (store, records, successful, eOpts) ->
			store.saveCriteriaIntoSession store
			return

	saveCriteriaIntoSession: (store) ->

	refreshCriteriaStore: (criteria) ->
		store = this

		getNegatedOp = (op) ->
			map = {}
			map["isNull"] = "isNotNull"
			map["in"] = "notIn"
			map[op]

		store.removeAll()
		if criteria isnt null
			for persistCriterion in criteria
				if persistCriterion.isNegated
					persistCriterion.operator = getNegatedOp(persistCriterion.operator)
					persistCriterion.isNegated = false
				@addItemCriteriaStore persistCriterion
			if criteria.length is 0
				store.fireEvent 'refresh', store
		return

	addItemCriteriaStore: (newOrUpdatedCriterion, triggerOwner) ->
		store = this
		criterionList = store.getCriteria()
		critClone = Ext.clone(criterionList)
		Corefw.model.FilterCriteria.setAggregationOrCompareInfo newOrUpdatedCriterion, triggerOwner
		criterionList = @addCriterion newOrUpdatedCriterion, criterionList

		store.loadData criterionList
		return true

	compare: (v1, v2) ->
		if not v1 or v1.length is 0
			v1 = null
		if not v2 or v2.length is 0
			v2 = null
		if v1 is 'null'
			v1 = null
		if v2 is 'null'
			v2 = null
		if v1 is v2
			return true
		return false

	getCriteriaFromRecord: (record) ->
		list = record.getChildren()
		if list
			ret = []
			fn = arguments.callee
			for item in list
				ret.push fn(item)
			return ret
		return record.data

	getCriteria: ->
		me = this
		criteria = []
		for item in me.data.items
			criteria = criteria.concat @getCriteriaFromRecord(item)
		if criteria.length < 1 then null else criteria

	replaceDateCriterion: (store, criObj) ->
		criterionList = store.getCriteria()
		replace = false
		newData = []
		if criterionList
			for criterion in criterionList
				if criterion.pathString.indexOf('Date') is -1
					newData.push criterion
				else
					newData.push criObj
					replace = true
		if not replace
			store.add criObj
		else
			store.loadData newData
		return

	getDateCriterionValue: (store) ->
		criterionList = store.getCriteria()
		if criterionList
			for criterion in criterionList
				if criterion.pathString.indexOf('/D:TimeMark-I:TimeMark Key') > -1
					return criterion.operandsString[0]
		return null

	equals: (store) ->
		if this is store
			return true
		if not (store instanceof Corefw.store.FilterCriteria)
			return false
		if not store
			return false
		if not @data
			if store.data
				return false
		else
			if not store.data
				return false
		if @data.length isnt store.data.length
			return false
		for item in @data.items
			if not item.equals store.data.items[i]
				return false
		return true

	addCriteionList: (addCriterionList) ->
		store = this
		criterionList = store.getCriteria()
		critClone = Ext.clone criterionList
		for criterion in addCriterionList
			critClone = @addCriterion criterion, critClone
		return critClone

	addCriterion: (newOrUpdatedCriterion, criterionList) ->
		replace = false
		if criterionList
			for criterion, index in criterionList
				if ( @compare(criterion.pathString, newOrUpdatedCriterion.pathString) and
					 @compare(criterion.compareMeasureName, newOrUpdatedCriterion.compareMeasureName) and
					 @compare(criterion.compareTimeoffset, newOrUpdatedCriterion.compareTimeoffset) and
					 @compare(criterion.aggregationMeasure, newOrUpdatedCriterion.aggregationMeasure) )
					replace = true
					if not newOrUpdatedCriterion.measure and (newOrUpdatedCriterion.operator is 'eq' or newOrUpdatedCriterion.operator is 'in') and (newOrUpdatedCriterion.operator is 'eq' or criterion.operator is 'in')
						criterion.dataTypeString = newOrUpdatedCriterion.dataTypeString
						if newOrUpdatedCriterion.from isnt undefined or newOrUpdatedCriterion.from is 'focus'
							criterion.operandsString = newOrUpdatedCriterion.operandsString
							criterion.operator = newOrUpdatedCriterion.operator
							continue
						if newOrUpdatedCriterion.replaceOps
							criterion.operandsString = newOrUpdatedCriterion.operandsString
						else
							criterion.operandsString = Ext.Array.merge criterion.operandsString, newOrUpdatedCriterion.operandsString
						if criterion.operandsString.length > 1
							criterion.operator = 'in'
						else
							criterion.operator = newOrUpdatedCriterion.operator
					else
						criterionList[index] = newOrUpdatedCriterion
		else
			criterionList = []
		if not replace
			criterionList.push newOrUpdatedCriterion
		criterionList