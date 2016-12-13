# commonly used functioned used in different parts of the app
Ext.define 'Corefw.util.Common',
	singleton: true
	styleHandlers:
		view:
			panel: (cfg, styleSetting) ->
				Ext.apply cfg, styleSetting
		perspective:
			tab: (cfg, styleSetting) ->
				defaults = {}
				tabStyle =
					tabBar:
						defaults: defaults
				for key, value of styleSetting
					defaults[key] = value
				Ext.apply cfg, tabStyle
			toolbar: (cfg, styleSetting) ->
				toolbarStyle =
					toolbarConfig: styleSetting
				Ext.apply cfg, toolbarStyle
		application:
			tab: (cfg, styleSetting) ->
				defaults = {}
				tabStyle =
					tabBar:
						defaults: defaults
				for key, value of styleSetting
					defaults[key] = value
				Ext.apply cfg, tabStyle
			panel: (cfg, styleSetting) ->
				Ext.apply cfg, styleSetting
# fastest way to clone an object
	objectClone: (obj) ->
		return Ext.clone obj

# given a string array of properties to copy,
# this will copy those properties from srcObj to destObj
# information is cloned so that a reference to the original object is not kept
# if moveFlag is TRUE, deletes the original property
	copyObjProperties: (destObj, srcObj, propArray, moveFlag) ->
		for prop in propArray
			val = srcObj[prop]
			if typeof val is 'undefined' or val is null
				continue

			if Ext.isArray(val) or Ext.isObject(val)
				destObj[prop] = Ext.clone val
			else
				destObj[prop] = val

			if moveFlag
				delete srcObj[prop]
		return

#TODO Not being used.
	mergeArrayOfObj: (destArr, srcArr) ->
		destArr = destArr or []
		srcArr = srcArr or []
		for srcObj in srcArr
			match = false
			for destObj in destArr
				if srcObj.uipath is destObj.uipath
					Ext.apply destObj, srcObj
					match = true
					break

			if not destArr.length or match is false
				destArr.push srcObj
		return destArr


# in an object, renames a property, but keeps the value
# the object old property is deleted
	objRenameProperty: (obj, oldPropertyName, newPropertyName) ->
		obj[newPropertyName] = obj[oldPropertyName]
		delete obj[oldPropertyName]
		return

# copy a property with new name, both properties will be kept
	objCopyProperty: (obj, oldPropertyName, newPropertyName) ->
		obj[newPropertyName] = @objectClone obj[oldPropertyName]
		return

	getAppName: ->
		className = this.$className
		sp = className.split '.'
		return sp[0]

# takes a variable and returns the corresponding Sencha Model field type
	valueToFieldType: (value) ->
		if Ext.isString value
			return 'string'
		if Ext.isNumber value
			return Ext.data.Types.NUMBER
		if Ext.isDate value
			return 'date'

	createTooltip: (targetEl, msg) ->
		return Ext.create 'Ext.tip.ToolTip',
			target: targetEl
			html: msg

# counting how many nodes in the tree
	getTreeNodesCount: (root) ->
		count = 1
		return count if root.childNodes.length is 0

		for childNode in root.childNodes
			count++;
			count += @getTreeNodesCount childNode
		return count

# counting how many nodes expanded in the tree
	getExpandedTreeNodesCountFromData: (root) ->
		count = 1
		return count if root.children.length is 0 or !root.expanded

		for childNode in root.children
			count += @getExpandedTreeNodesCountFromData childNode
		return count

# traverse all tree record and do something
	traverseTreeStore: (record, handler) ->
		handler?(record)
		return if record.childNodes.length is 0
		for r in record.childNodes
			@traverseTreeStore r, handler
		return

# conver the all of tree node cache data into the list, for retrieving node by index conveniently
	converTreeGridDataToDataList: (treeGridNodeList) ->
		gridData = {}
		for node in treeGridNodeList
			@traverseTreeNodeToGridData gridData, node, false
		return gridData

	traverseTreeNodeToGridData: (gridData, treeNode) ->
		gridData[treeNode.index] = treeNode
		childrenNodes = treeNode.children
		return if childrenNodes is 0
		for childrenNode in childrenNodes
			@traverseTreeNodeToGridData gridData, childrenNode
		return

	setThemeByGlobalVariable: (applicationName, currentCompName, compCfg) ->
		themeSetting = window[applicationName + '_theme']
		if themeSetting?
			currentCompStyle = themeSetting[currentCompName]
			if currentCompStyle?
				styleHandlers = @styleHandlers[currentCompStyle.level]
				for compType, styleCfg of currentCompStyle.styleSetting
					styleHandler = styleHandlers[compType]
					styleHandler? compCfg, styleCfg
		return

	parseDateData: (valueObj, fieldObj) ->
		for path, colValue of valueObj
			type = fieldObj[path]?.type?.toLowerCase()
			columnType = fieldObj[path]?.columnType?.toLowerCase()

			if (type is 'date' or columnType is 'date' or columnType is 'datetime') and colValue
				dt = new Date colValue
				valueObj[path] = dt
		return

	formSubmit: (comp, url, target)->
		#de = Corefw.util.Debug
		formPanel = Ext.create('Ext.form.Panel',
			standardSubmit: true
			method: "post")
		form = formPanel.getForm()

		if comp.generatePostData
			params = 
				data: Ext.JSON.encode comp.generatePostData()
		else
			params = comp.generatePostParams()
		action = Ext.create("Ext.form.action.StandardSubmit"
			form: form
			target: target
			params: params
			url: url)
		form.doAction(action);

		Ext.defer(()->
			form.destroy()
			return
		, 200)
		return

	download: (comp, url) ->
		url = url.replace 'api/delegator', 'api/delegator/download'
		frameName = "downloadIframe"
		if not frames[frameName]
			dlFrame = Ext.DomHelper.createDom {
				tag: "iframe"
				style:
					display: 'none'
				name: frameName
			}, Ext.getBody()
			dlFrame.onload = () ->
				try
					rtnStr = this.contentDocument.body.innerHTML
					if rtnStr
						jsonStr = rtnStr.substring(rtnStr.indexOf("{"), rtnStr.lastIndexOf("}") + 1)
						Corefw.util.Request.processResponseObject(JSON.parse(jsonStr))
				catch err
					console.error "Parsing error be found on download callback: #{err.message}"
				return
		@formSubmit comp, url, frameName
		return

	redirect: (comp, url) ->
		return if @processProhibited comp

		url = url.replace 'api/delegator', 'api/delegator/redirect'
		@formSubmit comp, url, "_blank"
		return

	getValueByFieldName: (fieldName, item, fn) ->
		if Ext.isArray item
			arr = []
			for single in item
				arr.push fn.call(this, single)
			return arr
		if Ext.isObject item
			if Ext.isArray fieldName
				for single in fieldName
					if item[single] isnt undefined
						return item[single]
			else
				return item[fieldName]
		else
			return item

	getDisplayValue: (item) ->
		return @getValueByFieldName ['displayValue', 'displayField'], item, arguments.callee

	getValue: (item) ->
		return @getValueByFieldName ['value', 'valueField'], item, arguments.callee

# calculate the height of horizontal scollbar
	getScrollBarHeight: ->
		el = document.createElement 'div'
		document.body.appendChild el
		el.style.display = 'hidden'
		el.style.overflowX = 'scroll'
		h = el.offsetHeight - el.clientHeight
		document.body.removeChild el
		return h

	processProhibited: (comp, isBeforeRender) ->
		return false if not comp or (!isBeforeRender and not comp.el) or comp.ownerCt?.xtype is "datepicker"
		xtype = comp.xtype
		return false if xtype is 'tab' #or xtype is 'combo'
		cu = Corefw.util.Uipath
		isEmpty = Ext.isEmpty

		if comp.isInlineFilter
			comp = comp.column

		# get parent component
		if comp.uipath
			parent = cu.uipathToParentComponent comp.uipath
		else
			parent = comp.up 'fieldcontainer'
		parent = @findParentFieldContainerByDomId comp.el?.dom?.id if not parent
		parentProps = parent?.cache?._myProperties or {}
		parentCompReadOnly = parentProps.readOnly

		compProps = comp?.cache?._myProperties
		if not compProps and parentProps.navs # comp is a tool bar
			compName = cu.uipathToShortName comp.uipath
			compProps = parentProps.navs[compName]
		compReadOnly = compProps?.readOnly
		return compReadOnly if not isEmpty compReadOnly

		# get perspective component
		perspective = comp.up '[coretype=perspective]'
		perspectiveProps = perspective?.cache?._myProperties or {}
		perspectiveReadOnly = perspectiveProps.readOnly or false

		# get view component
		view = comp.up '[coretype=view]'
		viewProps = view?.cache?._myProperties or {}
		viewReadOnly = viewProps.readOnly
		viewReadOnly = perspectiveReadOnly if isEmpty viewReadOnly # inherit perspective's readOnly

		# get element component
		element = comp.up '[coretype=element]'
		elementProps = element?.cache?._myProperties or {}
		elementReadOnly = elementProps.readOnly
		elementReadOnly = viewReadOnly if isEmpty elementReadOnly # inherit view's readOnly

		parentCompReadOnly = elementReadOnly if isEmpty parentCompReadOnly # inherit element's readOnly

		# generally. if parent status of read only is true,
		# the children of it will be prohibited to send request but child indicate the read only is false
		isProhibited = parentCompReadOnly or elementReadOnly or viewReadOnly or perspectiveReadOnly

		return isProhibited

# sometimes some component has no parent component by using up function.
# so you could use function to find their parent. Default find their field container
	findParentFieldContainerByDomId: (domId) ->
		fieldcontainers = Ext.ComponentQuery.query 'fieldcontainer[el]'
		domQuery = Ext.DomQuery.select
		qDomId = '#' + domId
		for ft in fieldcontainers
			domMatches = domQuery qDomId, ft.el.dom
			if domMatches.length > 0
				for dom in domMatches
					return ft if dom.id is domId
		return null

#	format value by specical style:
#	{TYPE}:{format string}
#	TYPE: NUMBER,DATE
#	example: NUMBER:0,000.00 -> will format the value based "0,000.00" as a number type
#	example: xxxx:0,000.00 -> the value will not be formatted because of there is not a type match the xxxx
	formatValueBySpecial: (value, format) ->
		linkNumberFormatter = (val, fStr) ->
			denominationRegExp = /[0,\.#]+(K|MM|BN)?$/
			isNumber = Ext.isNumber val
			if not isNumber
				return val
			if denominationRegExp.test fStr
				d2d =
					K: 1000
					MM: 1000000
					BN: 1000000000
				denomination = RegExp.$1
				divisor = d2d[denomination]
				if divisor
					val = val / divisor
			return Ext.util.Format.number val, fStr
		typeFormaters =
			NUMBER: linkNumberFormatter
			DATE: Ext.util.Format.date
		[type, fStr] = format.split ':'

		formater = typeFormaters[type]
		return value if not formater
		return formater value, fStr

# make the tree/grid view to drag/drop zone
	configureViewDragAndDrop: (comp, isGrid = true)->
		cache = comp.cache
		props = cache._myProperties
		isDraggable = props.draggable or false
		recievablePaths = props.recievablePaths or []
		isDroppable = recievablePaths.length > 0
		ptype = if isGrid then 'gridviewdragdrop' else 'treeviewdragdrop'
		dragFromUipath = props.uipath
		dragDropViewRender = @dragDropViewRender
		generateDragDropPostData = @generateDragDropPostData
		startUpObj = Corefw.util.Startup.getStartupObj()

		if isDraggable or isDroppable
			cfg =
				viewConfig:
					minHeight: 10
					plugins:
						ptype: ptype,
						ddGroup: if isGrid then 'GridDD' else 'TreeDD'
						enableDrag: isDraggable
						enableDrop: isDroppable
						onViewRender: (view)->
							dragDropViewRender @, view, isGrid, dragFromUipath
							return
					listeners:
						drop: (node, data, dropRec, dropPosition) ->
							#now the store of the grid has already added the dropped records,we should remove the records before we send the postData to backend
							grid = @up('grid')
							grid.getStore().remove data.records
							rq = Corefw.util.Request
							dragFromView = data.view
							# default dropToView should be the current view
							dropToView = if node.dataset then Ext.getCmp node.dataset.boundview else @
							return false if not dropToView
							dragFromView.getSelectionModel().select parseInt data.item.dataset.recordindex
							dragFromUipath = dragFromView.up('fieldcontainer')?.cache._myProperties.uipath
							dropToUipath = dropToView.up('fieldcontainer')?.cache._myProperties.uipath
							return if not dragFromUipath and not dropToUipath

							postData = generateDragDropPostData dragFromView, dropToView, dragFromUipath
							url = dropToUipath + '/ONDND/' + dragFromUipath
							url = rq.objsToUrl3 url
							rq.sendRequest5 url, rq.processResponseObject, dropToUipath, postData, 'The drag and drop request is failed', 'POST', null, null, null
							return
			if isGrid then Ext.apply comp, cfg else Ext.apply comp.treeConfig, cfg
		return

# a common drag and drop render for grid and tree
	dragDropViewRender: (me, view, isGrid, dragFromUiPath) ->
		if me.enableDrag
			if me.containerScroll
				scrollEl = view.getEl();
		view.copy = true
		dragCfg =
			view: view
			ddGroup: 'viewDD'
			dragText: me.dragText
			scrollEl: scrollEl
			beforeDragOver: (dropTo, e, id) ->
				recievablePaths = dropTo.view.up('fieldcontainer')?.cache._myProperties.recievablePaths or []
				if -1 < recievablePaths.indexOf dragFromUiPath
					return true
				else
					return false
			beforeDragDrop: (dropTo, e, id) ->
				records = @dragData.records
				for r in records
					# tree record
					if r.childNodes
						r.data.checked = true
					else
						@dragData.view.select r
				return true

		dropCfg =
			view: view
			ddGroup: 'viewDD'

		if isGrid
			if me.enableDrag
				dragCfg.containerScroll = me.containerScroll
				me.gridDragZone = new Ext.view.DragZone dragCfg
			if me.enableDrop
				gridDropZoneCfg =
					onNodeOut: (target, dd, e, data)->
						@hideIndicator()
					onNodeOver: (target, dd, e, data)->
						cls = Ext.dd.DropZone.prototype.dropAllowed
						columns = @view.getGridColumns()
						columnIndex = @getEventTargetIndex(e)
						@positionIndicator columnIndex
						@valid = true
						return cls
					hideIndicator: ()->
						@getTopIndicator().hide()
						@getBottomIndicator().hide()
						return
					positionIndicator: (columnIndex)->
						column = @view.getGridColumns()[columnIndex]
						if not column
							return
						@hideIndicator()
						topIndicator = @getTopIndicator()
						bottomIndicator = @getBottomIndicator()
						x = column.getX() + column.getWidth() - @indicatorXOffset
						topXY = [x, column.getY() - topIndicator.getHeight()]
						bottomXY = [x, column.getY() + column.getHeight()]
						topIndicator.show()
						bottomIndicator.show()
						topIndicator.setXY topXY
						bottomIndicator.setXY(bottomXY)
						return
					getEventTargetIndex: (e)->
						columns = @view.getGridColumns()
						eventX = e.getX();
						for column,index in columns
							columnX = column.getX()
							columnWidth = column.getWidth()
							if eventX > columnX and eventX < columnX + columnWidth
								return index
						return -1
					getTopIndicator: ()->
						if not @topIndicator
							@topIndicator = Ext.DomHelper.append Ext.getBody(),
								role: 'presentation',
								cls: "col-move-top",
								"data-sticky": true,
								html: "&#160;"
							, true
							@indicatorXOffset = Math.floor (@topIndicator.dom.offsetWidth + 1) / 2
						return @topIndicator
					getBottomIndicator: ()->
						if not @bottomIndicator
							@bottomIndicator = Ext.DomHelper.append Ext.getBody(),
								role: 'presentation',
								cls: "col-move-bottom",
								"data-sticky": true,
								html: "&#160;"
							, true
						return @bottomIndicator
				Ext.apply dropCfg, gridDropZoneCfg
				me.gridGropZone = new Ext.grid.ViewDropZone dropCfg
		else
			if me.enableDrag
				dragCfg.displayField = me.displayField
				dragCfg.repairHighlightColor = me.nodeHighlightColor
				dragCfg.repairHighlight = me.nodeHighlightOnRepair
				me.treeDragZone = new Ext.tree.ViewDragZone dragCfg
			if me.enableDrop
				dropCfg.allowContainerDrops = me.allowContainerDrops
				dropCfg.appendOnly = me.appendOnly
				dropCfg.allowParentInserts = me.allowParentInserts
				dropCfg.expandDelay = me.expandDelay
				dropCfg.dropHighlightColor = me.nodeHighlightColor
				dropCfg.dropHighlight = me.nodeHighlightOnDrop
				dropCfg.sortOnDrop = me.sortOnDrop
				dropCfg.containerScroll = me.containerScroll
				me.treeDropZone = new Ext.tree.ViewDropZone dropCfg
		return

	generateDragDropPostData: (dragFromComp, dropToComp, dragFromUipath)->
		dragFromPostData = dragFromComp.up('fieldcontainer').generatePostData()
		dropToPostData = dropToComp.up('fieldcontainer').generatePostData()
		dropToPostData.from = dragFromPostData
		dropToPostData.from.uipath = dragFromUipath
		return dropToPostData

# sometimes, index in record is not correct.so we have to get it by this function
	findRecordIndex: (store, record)->
		return -1 if not store or not record
		# handle tree store
		if tree = store.tree
			nodeList = @getNodeListFromTreeStore store
			nodeIndex = nodeList.indexOf record
			# root node will always be top node. but it doesn't be counted in index
			return nodeIndex - 1
		else if data = store.data
			return store.indexOf record
		else
			return -1

# to convert a tree node to a node list
	getNodeListFromTreeStore: (store)->
		nodeList = []
		root = store.tree.root
		loopNodes = (nodeList, node)->
			if node.childNodes.length is 0
				nodeList.push node
				return
			childNodes = node.childNodes
			nodeList.push node
			for n in childNodes
				loopNodes nodeList, n
			return
		loopNodes nodeList, root
		return nodeList

# set the min and max height to the grid,tree. It only be used when element form is VBOX layout
	setMaxAndMinHeight: (fieldCt) ->
		elementForm = fieldCt.up 'coreelementform'

		return if elementForm?.cache._myProperties.isAbsoluteLayout is true
		fieldProps = fieldCt.cache?._myProperties or {}

		return if not fieldCt.el
		childComp = fieldCt.grid or fieldCt.tree
		return if not childComp

		# sometime, The grid's or grid view's width will greater than its container's. so the vertical scroll bar will be overlap.
		# modify the grid width so that make the scroll bar show up.

		# get first row's height as the standard row height
		standardRowHeight = childComp.getView()?.getNode(0)?.offsetHeight
		# check the row height again. make sure the height is always available
		standardRowHeight = standardRowHeight or childComp.standardRowHeight or 21

		minRow = parseInt fieldProps.minRow
		maxRow = parseInt fieldProps.maxRow
		view = childComp.getView()
		return unless view
		if view.minHeight or view.maxHeight
			return

		if minRow
			minHeight = minRow * standardRowHeight
			@setMaxAndMinHeightToView view, false, minHeight

		if maxRow
			maxHeight = maxRow * standardRowHeight
			@setMaxAndMinHeightToView view, true, maxHeight
		return

	setMaxAndMinHeightToView: (view, isMax, height)->
		key = if isMax then "maxHeight" else "minHeight"
		if view.isLockingView
			view.lockedView[key] = height
			view.normalView[key] = height
		else
			view[key] = height
		return

	getKeyByValue: (v, obj) ->
		for key of obj
			if obj.hasOwnProperty(key) && obj[key] == v
				return key
		return

	preventBackspaceEvent: (event) ->
		if not event
			event = window.event

		keyCode = event.keyCode
		element = event.target || event.srcElement
		needPrevent = ((keyCode == 8) || (keyCode is 65 and event.ctrlKey)) && element.tagName != "TEXTAREA"
		if element.tagName == "INPUT"
			inputType = ["button", "color", "file", "image", "radio", "range", "reset", "submit"]
			needPrevent = needPrevent && ( element.type in inputType || element.readOnly || element.disabled)

		if needPrevent
			if not Ext.isIE
				event.stopPropagation()
			else
				event.returnValue = false
			return false
		return

	updateCommon: (widget, newProps) ->
		oldProps = widget.cache._myProperties
		oldTitile = oldProps.title
		newTitle = newProps.title
		oldVisible = oldProps.visible
		newVisible = newProps.visible
		oldEnabled = oldProps.enabled
		newEnabled = newProps.enabled

		if oldEnabled isnt newEnabled
			widget.setDisabled not newEnabled

		if widget.xtype is 'coreelementform' or widget.xtype is 'corecompositeelement'
			@updateElementHeader widget, newProps, widget.xtype is 'corecompositeelement'
			if newVisible isnt oldVisible
				widget.setVisible newVisible
		else
			if newTitle isnt oldTitile
				widget.setTitle newTitle
		if oldProps.cssclass isnt newProps.cssclass
			widget.removeCls oldProps.cssclass if oldProps.cssclass
			widget.addCls newProps.cssclass if newProps.cssclass

		return

	getSearchXtypeForDownload: (props) ->
		uip = Corefw.util.Uipath
		#su = Corefw.util.Startup
		parentType = props.widgetType?.toLowerCase()

		searchXtype = null
		switch parentType
			when 'form', 'form_based_element'
				searchXtype = 'form'
			when 'table', 'objectgrid', 'object_grid'
				searchXtype = 'grid'
			when 'fieldset'
				searchXtype = 'corefieldset'
			when 'rcgrid'
				searchXtype = 'corercgrid'
			when 'tree_grid'
				searchXtype = 'coretreegrid'
			when 'view'
				searchXtype = '[coretype=view]'
			when 'perspective'
				searchXtype = 'coreperspective'
			when 'chart'
				searchXtype = 'corechartfield'
			when 'tree'
				searchXtype = 'coretreesimple'
			when 'composite_element'
				searchXtype = 'corecompositeelement'
			when 'breadcrumb'
				searchXtype = '[coretype=breadcrumb]'
			else
				console.log 'onNavClickEvent unable to find parentType: ', parentType
				if typeof parentType is 'undefined'
					coretype = props.coretype
				else if parentType is 'toolbar'
					parentCache = uip.uipathToParentCacheItem props.uipath
					parentProps = parentCache._myProperties
					coretype = parentProps.coretype
				switch coretype
					when 'element'
						searchXtype = 'form'
					when 'view'
						searchXtype = '[coretype=view]'
					when 'perspective'
						searchXtype = 'coreperspective'
					when 'compositeElement'
						searchXtype = 'corecompositeelement'
		return    searchXtype

	updateElementHeader: (comp, newProps, isCompEl) ->
		me = comp
		oldProps = me.cache._myProperties
		oTitle = oldProps.title
		nTitle = newProps.title
		su = Corefw.util.Startup
		#TODO? oTitle is null, nTitle isnt null
		# If new title is null, remove current header
		if not nTitle
			me.removeDocked me.header if oTitle
		#return Commented. otherwise tooltips, expand/collapse will not be updated.

		if nTitle
			# update header title if it has header and title get changed
			if oTitle
				if oldProps.collapsible and isCompEl and not su.getThemeVersion()
					nTitle = '&nbsp;&nbsp;&nbsp;' + nTitle
				me.title = nTitle
				delete me.originalTitle

			if not me.originalTitle or (oldProps.secondTitle isnt newProps.secondTitle)
				me.secondTitle = newProps.secondTitle
				secondTitleCmp = me.secondTitleCmp
				me.header.remove secondTitleCmp if secondTitleCmp
				delete me.secondTitleCmp
			# update element header title/second title
			# TODO re-factor Render.addSecondTitle, it's adding title & second title both!
			if not me.originalTitle or (me.secondTitle and not me.secondTitleCmp)
				Corefw.util.Render.addSecondTitle me
		oTitle = nTitle # to make sure collapsible code works fine.

		#update tooltip
		if oldProps.toolTip isnt newProps.toolTip
			me.header?.el?.set? 'data-qtip': newProps.toolTip

		#TODO? support collapsible change
		if oldProps.collapsible isnt newProps.collapsible
			return

		nExpanded = newProps.expanded
		oExpanded = not me.collapsed
		# don't expand/collapse if me is a tab at tabpanel
		# don't expand/collapse if me isnt collapsible
		# don't expand/collapse if me doesn't have title
		# don't expand/collapse if me isnt visible
		if me.el?.hasCls?("#{Ext.baseCSSPrefix}tabpanel-child") or not oldProps.collapsible or not oTitle or not newProps.visible
			return
		# update expand/collapse if element expand/collapse get changed.
		if nExpanded isnt oExpanded
			if nExpanded
				me.expand()
			else
				me.collapse()
		return

	stripHtml: (html)->
		tmp = document.createElement "TDIV"
		tmp.innerHTML = html
		return Ext.String.trim(tmp.textContent or tmp.innerText or "")