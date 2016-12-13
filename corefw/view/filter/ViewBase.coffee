Ext.define 'Corefw.view.filter.ViewBase',
	extend: 'Ext.view.View'
	alias: 'widget.filterViewBase'
	requires: [
		'Corefw.util.Formatter'
	]
	componentCls: 'cv-filter'
	itemSelector: 'div.cv-filter-item'
	deferEmptyText: false
	emptyText: 'No Criterion Applied'
	minHeight: 25
	autoScroll: true
	singleCriterionStyle: ''
	singleCriterionCls: ''
	selectedRecords: []
	showOnlyCls: 'showOnly'
	itemSelectedCls: 'selected'
	itemUnselectedCls: ''
	itemCls: ''
	isCriteriaGlobal: true
	showOnly: false
	headerText: ''

	getDragContent: (itemIndex) ->
		node = @getNode itemIndex
		contentEle = node.getElementsByTagName('span')[0]
		contentEle.innerHTML

	initComponent: ->
		me = this
		Ext.apply @listeners, @extraListeners
		tplArr = if @headerText then ['<div class="cv-filter-header">' + @headerText + '</div>'] else []
		tplArr = tplArr.concat [
			'<tpl for=".">'
			'<div class="cv-filter-item' + @singleCriterionCls + ' ' + @itemCls + ' {[this.getAdditionCls()]}" style="' + @singleCriterionStyle + '">'
		]
		spanCls = @showOnlyCls
		@dragContents = []
		if not @showOnly
			tplArr.push '<span align="right" data-qtip="Remove" style="{[this.displayDeleteIcon(values)]}"  class="f-action icon-delete"> </span>'
			tplArr.push '<span align="right" data-qtip="Filter" style="{[this.displayFilterIcon(values)]}"  class="f-action icon-filter"> </span>'
			spanCls = ''
		tplArr = tplArr.concat [
			'{[this.getHeader(values)]}'
			'</div>'
			'</tpl>'
		]
		@tpl = Ext.create 'Ext.XTemplate', tplArr.join(''),
			compiled: true
			getAdditionCls: ->
				''
			getHeader: (criObject) ->
				store = me.getStore()
				criObj = store.getCriObjByPath criObject.pathString
				tips = []
				txts = []
				info = null
		
				getSingle = (criObj) ->
					result = Corefw.model.FilterCriteria.getCriteriaLabel criObj
					retValue = if result then result[0] else null
					ops = if result then result[1] else null
					replaceReg = /(.+)<sub>(.+)<\/sub>(.+)/i
					newTips = retValue.replace replaceReg, '$1[$2]$3'
					pathString = criObj.pathString
					domainPathInfo = ''
					domainPathInfo += /^\/D:([^-]*)/.exec(pathString)[1]
					domainPathInfo += ' --> '
					re4FindDDR = /R:([^-]*)\/D:[^-]*/
					while re4FindDDR.test pathString
						domainPathInfo += re4FindDDR.exec(pathString)[1]
						pathString = pathString.replace re4FindDDR, ''
						domainPathInfo += ' --> '
					domainPathInfo += /I:([^-]*)$/.exec(pathString)[1]
					domainPathInfo = domainPathInfo.replace /@[A-Za-z]*/g, ''
					newTips = newTips.replace criObj.itemName, domainPathInfo
					{
						tip: newTips
						text: retValue
					}
		
				isGray = (criObj) ->
					criObj.disabled or criObj.elementAggregationColumnNotExisted or criObj.elementComparisonColumnNotExisted
		
				if Ext.isArray criObj
					for obj in criObj
						info = getSingle obj
						tips.push info.tip
						txts.push info.text
				else
					info = getSingle criObj
					tips.push info.tip
					txts.push info.text
				if isGray criObject
					'<span style="color:#999999;font-style:italic;" title="' + tips.join('\n') + '" class="' + spanCls + '">' + txts.join(';') + '</span>'
				else
					'<span title="' + tips.join('\n') + '" class="' + spanCls + '">' + txts.join(';') + '</span>'
			displayFilter: (criObj) ->
				if not criObj
					return ''
				if criObj.disabled or criObj.elementAggregationColumnNotExisted or criObj.elementComparisonColumnNotExisted
					'display:none;'
				else
					''
			displayDeleteIcon: (criObj) ->
				if me.getStore().isGlobal and me.getStore().isTimeMarkPath(criObj.pathString)
					'display:none;'
				else
					''
			displayFilterIcon: (criObj) ->
				if criObj.disabled or criObj.elementAggregationColumnNotExisted or criObj.elementComparisonColumnNotExisted
					'display:none;'
				else
					'margin:0px 3px 0px 0px;'
		@store = Ext.create 'Corefw.store.FilterCriteria',
			storeId: Ext.id()
			isGlobal: @isCriteriaGlobal
			dataView: this
		@callParent arguments
		return

	_converArgToArray: (input) ->
		if not input instanceof Array
			input = [ input ]
		return input

	reLoadCriteria: (criteria) ->
		@store.loadData criteria
		return

	removeRecord: (itemRecords) ->
		itemRecords = @_converArgToArray itemRecords
		toRemain = []
		while itemRecords.length
			rec = itemRecords.pop()
			@store.each (storeRec)->
				if not storeRec.equals rec
					toRemain = toRemain.concat @store.getCriteriaFromRecord(storeRec)
		@store.refreshCriteriaStore toRemain
		return

	receiveCriteria: (criteria) ->
		old_criteria = @store.getCriteria()
		criteria = @_converArgToArray criteria
		if not old_criteria
			@store.refreshCriteriaStore criteria
		else
			@store.refreshCriteriaStore @_composeCriteria(old_criteria, criteria)
		return

	_composeCriteria: (oldCriteria, newCriteria) ->
		results = []
		results = result.concat oldCriteria
		for criteria in newCriteria
			isAddToResult = true
			for result, index in results
				if Corefw.model.FilterCriteria.isTwoCriteriaFilterFieldSame result, criteria
					isAddToResult = false
					results[index] = criteria
					break
			if isAddToResult
				results.push criteria
		return results

	getFilteredStore: Ext.emptyFn
	afterItemDelete: Ext.emptyFn

	afterClickCloseIcon: (record) ->
		if not Ext.Array.contains @selectedRecords, record
			@selectedRecords.push record
		if @getStore().isGlobal
			for recd in @selectedRecords
				if recd.get('dataTypeString') is 'date' and Corefw.model.FilterCriteria.fiscalRegex.test(recd.get('pathString'))
					@selectedRecords = Ext.Array.remove @selectedRecords, recd
		@store.remove @selectedRecords
		@selectedItems = []
		@afterItemDelete()
		return

	afterClickFilterIcon: (record, item, position, underCollection) ->

	setMenuPosition: (e) ->
		[
			e.getX() - 140
			e.getY() + 20
		]

	_deselectAll: ->
		if @selectedItems
			for selectedItem in @selectedItems
				Ext.fly(selectedItem).removeCls(@itemSelectedCls).addCls @itemUnselectedCls
		@selectedItems = []
		@selectedRecords = []
		return

	_select: (dom, record) ->
		dom.selected = true
		Ext.fly(dom).addCls(@itemSelectedCls).removeCls @itemUnselectedCls
		if @selectedItems
			@selectedItems.push dom
			@selectedRecords.push record
		else
			@selectedItems = [ dom ]
			@selectedRecords = [ record ]
		return

	_deselect: (dom, record) ->
		dom.selected = false
		Ext.fly(dom).removeCls(@itemSelectedCls).addCls @itemUnselectedCls
		Ext.Array.remove @selectedItems, dom
		Ext.Array.remove @selectedRecords, record
		return

	_clickWithShift: (item, index) ->
		first = @shiftSelected[0]
		@_deselectAll()
		if first or first == 0
			i = first
			delt = if first > index then -1 else 1
			loop
				dom = item.parentNode.childNodes[i]
				@_select dom, @dataSource.data.getByKey(dom.viewRecordId)
				if i == index
					break
				i += delt
		else
			@_select item, record
		if @shiftSelected
			@shiftSelected.push index
		else
			@shiftSelected = [ index ]
		return

	_clickWithCtrl: (item, record, index) ->
		if item.selected
			@_deselect item, record
		else
			@_select item, record
		@shiftSelected = [ index ]
		return

	_singleItemSelect: (item, record, index) ->
		@_deselectAll()
		@_select item, record
		@shiftSelected = [ index ]
		return

	selectCriteria: (item, record, index, e) ->
		if not (e.ctrlKey or e.shiftKey)
			@_singleItemSelect item, record, index
		else if e.shiftKey
			@_clickWithShift item, index
		else if e.ctrlKey
			@_clickWithCtrl item, record, index
		return

	afertClickOperationIcon: (targetEl, item, record, e) ->
		if targetEl.hasCls('icon-delete')
			@afterClickCloseIcon record
		else
			criteria = record.get('operandsString')
			underCollection = false
			criteria = if criteria.length is 0 then [ '' ] else criteria
			if criteria[0].operator
				underCollection = true
			@afterClickFilterIcon record, item, @setMenuPosition(e), underCollection
		return
		
	listeners:
		itemmouseleave: (view, record, item, index, e, eOpts) ->
			if Ext.fly(item).is(@itemUnselectedCls)
				Ext.fly(item).removeCls @itemUnselectedCls
			return
		itemclick: (th, record, item, index, e, eOpts) ->
			elem = Ext.fly e.target
			if elem.hasCls 'f-action'
				th.afertClickOperationIcon elem, item, record, e
			else
				th.selectCriteria item, record, index, e
			th.preClicked =
				index: index
				shiftKey: e.shiftKey
			e.stopEvent()
			e.preventDefault()
			false