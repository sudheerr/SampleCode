Ext.define 'Corefw.view.tree.TreeSimpleField',
	extend: 'Corefw.view.tree.TreeFieldBase'
	xtype: 'coretreesimple'



# configure tree properties, overrides base class method
# parent class sets the value of firstColumnName
	configureTree: ->
		@callParent arguments
		@treeConfig.displayField = @firstColumnName
		return


	generatePostData: ->
		@generateNewPostData()

	generateNewPostData: ->
		senchaTree = @tree
		displayField = senchaTree.displayField
		props = @cache._myProperties
		children = []
		postData =
			name: props.name
			allTopLevelNodes: children
			expandingNodeId: @expandingNodeId
		st = senchaTree.getStore()
		rootObj = st.tree.root
		treeSelectModel = senchaTree.getSelectionModel()
		# postChildArray: children array (usually empty) of the post data that will be sent back
		# storeChildArray: the children array of the store, that contains the source data
		generateNewPostDataCreateChildren = (postChildArray, storeChildArray) ->
			for storeChild in storeChildArray
				rawData = storeChild.raw
				data = storeChild.data
				valueObj = {}
				valueObj[displayField] = data[displayField]
				newChildObj =
					'new': false
					changed: false
					removed: false
					index: data.id
					selected: data.checked
					value: valueObj
					expanded: data.expanded
					editing: if storeChild.isEditing then true else false
				if not rawData.semiSelected
					newChildObj.changed = (rawData.origSelected isnt data.checked)
				# TODO remove all @dblClickedRecord, @clickedRecord, it looks useless, we just use treeSelectModel to set selected is ok
				dblClickedRecord = @dblClickedRecord
				clickedRecord = @clickedRecord
				if (data.checked and not dblClickedRecord) or (dblClickedRecord and data is dblClickedRecord.data)
					newChildObj.selected = true
				else if(data.checked and not clickedRecord) or (clickedRecord and data is clickedRecord.data)
					newChildObj.selected = true
				else
					newChildObj.selected = false

				if props.selectType is 'NONE' and treeSelectModel.isSelected storeChild
					newChildObj.selected = true

				postChildArray.push newChildObj
				if storeChild.childNodes and storeChild.childNodes.length
					subChildren = []
					newChildObj.children = subChildren
					generateNewPostDataCreateChildren subChildren, storeChild.childNodes
			return

		if rootObj.childNodes and rootObj.childNodes.length
			generateNewPostDataCreateChildren children, rootObj.childNodes
		return postData


	treeItemClickHandler: (record, treenodeDom, index, ev, callback, isDblClick) ->
		rq = Corefw.util.Request
		uipath = @uipath
		iv = Corefw.util.InternalVar
		isClickBlocked = iv.getByNameProperty uipath, 'treeItemClickEventsBlocked'
		if isClickBlocked
			console.log 'click event blocked'
			return
		record.isEditing = true
		@dblClickedRecord = record
		postData = @generatePostData()
		record.isEditing = false
		delete @dblClickedRecord
		delete @clickedRecord
		url = if isDblClick then rq.objsToUrl3 @eventURLs['ONDOUBLECLICK'] else rq.objsToUrl3 @eventURLs['ONCLICK']
		errMsg = 'Did not receive a valid response for the tree leaf'
		method = 'POST'
		if typeof callback is 'function'
			processCallBack = (respObj, ev, uipath, preProcess)->
				rq.processResponseObject respObj, ev, uipath, preProcess
				callback respObj, ev, uipath, preProcess
				return
		else
			processCallBack = rq.processResponseObject
		rq.sendRequest5 url, processCallBack, uipath, postData, errMsg, method, undefined, ev
		iv.setByNameProperty uipath, 'treeItemClickEventsBlocked', true
		return

	treeItemLinkClickHandler: (record, treenodeDom, index, ev, callback, isDblClick) ->
		rq = Corefw.util.Request
		cm = Corefw.util.Common
		redirectURL = rq.objsToUrl3 @eventURLs['ONREDIRECT']
		downloadURL =  rq.objsToUrl3 @eventURLs['ONDOWNLOAD']
		if redirectURL
			cm.redirect this, redirectURL
		else if downloadURL
			cm.download this, downloadURL
		return

	onDBLClickSimpleTreeItem: (record, treenodeDom, index, ev, callback) ->
		@treeItemClickHandler record, treenodeDom, index, ev, callback, true
		return
	onClickSimpleTreeItem: (record, treenodeDom, index, ev) ->
		@treeItemClickHandler record, treenodeDom, index, ev, callback, false
		return