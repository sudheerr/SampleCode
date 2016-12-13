Ext.define 'Corefw.view.layout.AbsoluteLayoutManager',
	extend: 'Corefw.view.layout.LayoutManager'
	constructor: (config) ->
		@callParent arguments
		comp = config.comp
		comp.layout = 'absolute'
		@setLayoutVariables(comp)
		return

	validate: ->
		comp = @comp
		cache = comp.cache
		props = cache._myProperties
		layout = props.layout
		contents = @getContentsFromCache cache
		navs = @getNavsFromProps props
		return false if not (layout and layout.columnCount and layout.rowCount)
		# fieldsNeedValidation contain all contents and all navs (https://www.citi.net/jira/browse/1615346-3647)
		fieldsNeedValidation = []
		for content in contents
			fieldsNeedValidation.push content

		for nav in navs
			fieldsNeedValidation.push nav

		if not fieldsNeedValidation.length or not @checkForCollisions props, fieldsNeedValidation
			return false
		return true

	removeAll: ->
		comp = @comp
		comp.removeAll()
		return

	initLayout: ->
		comp = @comp
		contentDefs = comp.contentDefs
		for contentDef in contentDefs
			@applyContentConfig contentDef
		comp.add contentDefs
		@lv.navrow = []
		@addShim()
		return

	getMessageBannerHeight: ->
		height = 30 # default message height
		div = document.createElement 'div'
		div.classList.add 'statusView'
		document.body.appendChild div
		height or= div.clientHeight
		document.body.removeChild div
		return height

# put a little space around 4px at the bottom
	addShim: ->
		su = Corefw.util.Startup
		numRows = @lv.numRows
		comp = @comp
		shimobj =
			xtype: 'component'
			html: ''
			style:
				marginBottom: '1px'
			shim: true
			orig:
				x: 0
				y: numRows
				xsize: 0.1
				ysize: 0

		@setXY
			content: shimobj
			coord: shimobj.orig

		if su.getThemeVersion() isnt 2
			shimobj.y = shimobj.y - 5 if shimobj.y
		comp.add shimobj
		return


	applyContentConfig: (contentDef) ->
		props = contentDef.cache?._myProperties
		coord = props.coordinate
		contentDef.orig =
			x: coord.x
			y: coord.y
			xsize: coord.xsize
			ysize: coord.ysize
		@setXY
			content: contentDef
			coord: coord
			buttonHeight: contentDef.buttonHeight
		return

	beforeAddContent: (contentDef) ->
		@applyContentConfig contentDef
		return

	addStatus: (statusDef) ->
		me = this
		statusDef.orig =
			x: 0
			y: 0
			xsize: me.lv.numCols
			ysize: 1
		statusDef.listeners =
			statusremoved: (comp, store) ->
				me.adjustFieldPositions store.getCount()
				me.comp.doComponentLayout()
				return
			statusviewremoved: ->
				me.adjustFieldPositions 0
				me.comp.doComponentLayout()
				return
		me.adjustFieldPositions statusDef.statusMsgs.length
		me.setXY
			content: statusDef
			coord: statusDef.orig
		me.comp.add statusDef
		return
	#TODO add toolbar to top
	addToolbar: (toolbarDef) ->
		me = this
		lv = me.lv
		su = Corefw.util.Startup


		toolbarCoord =
			x: 0
			y: lv.numRows
			xsize: lv.numCols
			ysize: 1

		toolbarContainer =
			xtype: 'container'
			items: [toolbarDef]
			orig: toolbarCoord

		if su.getThemeVersion() is 2 and toolbarDef.bottomContainer
			toolbarContainer.bottomContainer = true

		me.setXY
			content: toolbarContainer
			coord: toolbarCoord

		me.comp.add toolbarContainer
		return

# adjust all the fields in the form depending on how many error messages there are
	adjustFieldPositions: (numMsgs) ->
		cm = Corefw.util.Common
		lv = @lv

		lv.numRows = lv.origNumRows + numMsgs
#		@setLayoutVariables(@comp)

		items = @comp.items.items
		for item in items
			orig = item.orig
			oldCoords = cm.objectClone item.orig
			if not orig.restore
				orig.restore = oldCoords
			orig.y = orig.restore.y + numMsgs

			if item.xtype is 'button'
				@setXY
					content: item
					coord: orig
					buttonHeight: item.height
			else if item.xtype is 'statusview'
				continue
			else
				@setXY
					content: item
					coord: orig

			if item.el
				item.setLocalX item.x
				item.setLocalY item.y

		return
	getNavsFromProps: (props) ->
		navs = []
		for key, field of props.navs
			if key isnt '_ar' and field.visible
				navs.push field
		return navs
	getContentsFromCache: (cache) ->
		fields = []

		# add all the fields to the fields array
		# except removed and invisible
		for key, field of cache
			fieldProps = field?._myProperties
			if key isnt '_myProperties' and fieldProps and fieldProps.widgetType isnt 'TOOLBAR' and not fieldProps.isRemovedFromUI and fieldProps.visible
				fields.push field

		return fields
	checkForCollisions: (props, fields) ->
		me = this
		inBounds = me.checkBounds props, fields

		if not inBounds
			return false

		layoutObj = {}

		# for each item, place it in the layout grid
		for field in fields
			props = if field._myProperties? then field._myProperties else field

			coord = props.coordinate
			if not coord and field.widgetType is 'NAVIGATION'
				continue

			x = coord.x
			xsize = coord.xsize
			y = coord.y
			ysize = coord.ysize

			for yindex in [y... y + ysize]
				yobj = layoutObj[yindex]
				if not yobj
					yobj = {}
					layoutObj[yindex] = yobj

				for xindex in [x... x + xsize]
					tempobj = yobj[xindex]
					if tempobj
						# if a previous object was placed here
						# return an error
						console.log 'ERROR: Location conflicts'
						console.log 'You are trying to place two objects into the same location'
						console.log 'Previous object: ', tempobj.uipath
						console.log 'Current object : ', props.uipath
						return false
					else
						yobj[xindex] = props

		return true

# check to make sure all coordinates are within bounds
# 0-based index
# if xstart+xsize > numberOfColumns, then part or all of the component is out of bounds
# if ystart+ysize > numberOfRows, then part or all of the component is out of bounds
	checkBounds: (props, fields) ->
		numColsTotal = props.layout.columnCount
		numRowsTotal = props.layout.rowCount
		# console.log numColsTotal, numRowsTotal

		defaults =
			xsize: 1
			ysize: 1
			x: 0
			y: 0

		for field in fields
			props = if field._myProperties? then field._myProperties else field

			coord = props.coordinate

			# avoid coord related crash
			if not coord
				if props.widgetType is 'NAVIGATION'
					continue
				coord = {}
				props.coordinate = coord

			# apply defaults if it doesn't exist on the object
			Ext.applyIf coord, defaults

			if (coord.x + coord.xsize > numColsTotal) or (coord.x < 0) or (coord.xsize <= 0)
				console.log "ERROR: Label \"#{props.name}\" dimensions wrong."
				console.log "Attempting to declare: X:#{coord.x}, xsize:#{coord.xsize}, number of columns: #{numColsTotal}"
				return false

			if (coord.y + coord.ysize > numRowsTotal) or (coord.y < 0) or (coord.ysize <= 0)
				console.log "ERROR: Label \"#{props.name}\" dimensions wrong."
				console.log "Attempting to declare: Y:#{coord.y}, ysize:#{coord.ysize}, number of rows: #{numRowsTotal}"
				return false

		return true

	setLayoutVariables: (comp) ->
		rdr = Corefw.util.Render
		cm = Corefw.util.Common
		su = Corefw.util.Startup
		lv = cm.objectClone rdr.layoutVars
		layout = comp?.cache?._myProperties?.layout
		if layout
			numCols = layout.columnCount
			numRows = layout.rowCount
			lv.numCols = numCols
			lv.numRows = numRows
			lv.origNumCols = numCols
			lv.origNumRows = numRows
		if su.getThemeVersion() is 2
			lv.fieldHMargin = 8 if lv.fieldHMargin
			lv.panelRowHeight = 63 if lv.panelRowHeight
			lv.fieldHeight = 48 if lv.fieldHeight

			# Set space between rows in form with fields
			# First divide into groups by type. Group1-- checkbox, checkgroup, radiogroup.
			# Group2-- Togglebutton. Group3-- label,link.
			# Default is combobox,textfield,numberfield
			# Cases considered. Rows with Group1 or Group2 or Group3 or default and combination of these groups
			# Eg: if a row in field container has only checkbox's, the row height should be 44px not 48px.
			# default group row height is 48px
			lv.buttoncontainerheight = 43
			lv.labelrow = []
			lv.checkboxrow = []
			lv.navrow = []
			lv.rows = []
			normalrows = []
			if numCols and numRows
				cache = comp.cache
				numofitems = []
				for fielditem, value of cache
					if fielditem isnt '_myProperties'
						props = value._myProperties
						coordinate = props.coordinate
						if coordinate and coordinate.y isnt 'undefined' and normalrows[coordinate.y] is undefined
							lv.rows[coordinate.y] = true
							if props.type in rdr.labelTypes
								lv.labelrow[coordinate.y] = 49
							else
								if props.type in rdr.checkboxTypes
									lv.checkboxrow[coordinate.y] = 49
									delete lv.labelrow[coordinate.y] if lv.labelrow
								else
									delete lv.checkboxrow[coordinate.y] if lv.checkboxrow
									delete lv.labelrow[coordinate.y] if lv.labelrow
									normalrows[coordinate.y] = true
						else
							continue

				for fielditem, value of cache
					if fielditem isnt '_myProperties'
						#console.log 'fielditem, value-----------------------',fielditem,value
						props = value._myProperties
						continue unless (props.visible and props.coordinate)
						x = props.coordinate.x
						y = props.coordinate.y

						lv.navrow[y] = -1
						if props.type in rdr.labelTypes and not Ext.isNumber(lv.labelrow[y]) and not Ext.isNumber(lv.checkboxrow[y])
							Corefw.util.InternalVar.setByUipathProperty props.uipath, 'mixed-form-element', true
						if numofitems.length
							for num, value of numofitems
								#console.log 'num,valofindex,numofitems,numofitems.length-----------------',num,valofindex,value,numofitems,numofitems.length
								if x is value
									#console.log 'x,num,value----------------------',x,num,value
									break
								valofindex = Ext.Array.indexOf numofitems, value
								if (valofindex + 1) is numofitems.length
									#console.log 'props,coordinate,x-------------------',props,props.coordinate,x
									numofitems.push x

						else
							numofitems.push x
				#console.log 'numofitems----------------------------',numofitems
				if numofitems.length >= numCols
					lv.fieldHMargin = 22

				for fielditem, value of cache
					if fielditem is '_myProperties'
						allNavigations = value.allNavigations
						length = allNavigations.length if allNavigations
						if length
							for nav in allNavigations
								y = nav?.coordinate?.y
								lv.navrow[y] = lv.buttoncontainerheight if y and lv.navrow[y] isnt -1
					else
						props = value._myProperties
						widgetType = props.widgetType if props
						if widgetType and widgetType is 'FIELD'
							if comp.padding
								lv.leftMargin = 0
								lv.topMargin = 0
								comp.padding = '15 15 0 15' #apply padding for forms in toolbar
								break
							else
								#for forms other than in toolbar set leftMargin and topMargin to set the padding around form
								lv.leftMargin = 15
								lv.topMargin = 15
								lv.rightMargin = 15
				Ext.Object.each lv.navrow, (index, item) ->
					delete lv.navrow[index] if item is -1
		numRows or= 0
		lv.fieldHeightExtra = lv.panelRowHeight - lv.fieldHeight
		lv.totalHeight = lv.panelRowHeight * numRows + lv.panelHeaderHeight * 2 + lv.topMargin * 2 + 100

		if comp.getEl()
			compWidth = comp.getWidth() or 0
		else
			compWidth = comp.width or 0
		lv.fieldTotalWidth = (compWidth - 2) / numCols # multiply this to get the field location coords
		lv.fieldWidth = lv.fieldTotalWidth - lv.leftMargin - lv.rightMargin # set the field's actual width to this

		comp.lv = lv
		@lv = lv
		return

	# given x/y and xsize/ysize, sets the pixel x/y and width/height
	# buttonHeight is optional, and is only passed in when we're laying out a button
	setXY: (config) ->
		#container = @comp
		su = Corefw.util.Startup
		rdr = Corefw.util.Render
		content = config.content
		coordObj = config.coord
		buttonHeight = config.buttonHeight
		lv = @lv

		# init content width to 0, will get changed at onResize events
		content.x = lv.leftMargin
		content.width = 0
		if su.getThemeVersion() is 2
			labelrow = lv.labelrow
			checkboxrow = lv.checkboxrow
			navrow = lv.navrow
			if labelrow.length or checkboxrow.length or navrow.length
				reduceheight = @reduceY(lv.rows, labelrow, checkboxrow, navrow, config)
				content.y = coordObj.y * lv.panelRowHeight + lv.topMargin - reduceheight
			else
				content.y = coordObj.y * lv.panelRowHeight + lv.topMargin
		else
			content.y = coordObj.y * lv.panelRowHeight + lv.topMargin

		extraMarginHeight = 0

		#Field height calculation
		#1. Get height (fieldheight) according to ysize
		#2. Add extra height (panelRowHeight - fieldHeight)
		if coordObj.ysize > 1
			extraMarginHeight = (lv.panelRowHeight - lv.fieldHeight) * Math.ceil Math.abs coordObj.ysize - 1

		tempheight = lv.fieldHeight * coordObj.ysize + extraMarginHeight
		# Below code is just vertically centering the button
		# TODO we might use padding or margin to do the centering.
		if buttonHeight
			diffHeight = lv.fieldHeight - buttonHeight
			if su.getThemeVersion() is 2
				if not lv.navrow[coordObj.y]
					content.y += diffHeight
			else
				content.y += diffHeight + 2

			content.height = buttonHeight
			content.maxHeight = buttonHeight
		else
			if su.getThemeVersion() is 2 and content.bottomContainer
				content.height = 43
				delete content.bottomContainer
			else
				content.height = tempheight
				content.maxHeight = tempheight
		return

# assumption: height stays the same
# this function only gets called when width changes
# only make width changes
	resize: ->
		comp = @comp
		lv = comp.lv
		numCols = lv.numCols
		numRows = lv.numRows

		leftMargin = lv.leftMargin
		rightMargin = lv.rightMargin
		fieldHMargin = lv.fieldHMargin

		if not comp.rendered or not comp.body
			return

		compBody = comp.body
		#fix issue for chrome version 43 filed set body with not change when element with changed
		if compBody.getWidth() is 0 and comp.xtype is 'corefieldset' and comp.width > 0
			compBody.setWidth comp.width
		compBodySize = compBody.getSize true
		fieldTotalWidth = compBodySize.width - leftMargin - rightMargin
		fieldWidth = (fieldTotalWidth - fieldHMargin * (numCols - 1)) / numCols

		items = comp.items.items

		if items
			for item in items
				if item.rendered
					itemX = item.orig.x
					itemXSize = item.orig.xsize
					#Field localX calculation
					#1. Get width (exclude field margin) according to x
					#2. Add extra field margins
					#3. Add panel left margin
					localX = itemX * fieldWidth + leftMargin + fieldHMargin * Math.floor itemX
					#Field width calculation
					#1. Get width (exclude field margin) according to xsize
					#2. Add extra field margins
					tempwidth = fieldWidth * itemXSize
					if itemXSize > 1
						tempwidth += fieldHMargin * Math.ceil itemXSize - 1

					item.setLocalX localX
					item.setWidth tempwidth
		return

	reduceY: (rows, labelrow, checkboxrow, navrow, config) ->
		coordObj = config.coord
		panelRowHeight = 63
		decreaseheight = 0
		for y of rows when y < coordObj.y
			if checkboxrow[y]
				decreaseheight = decreaseheight + panelRowHeight - checkboxrow[y]
				continue
			else
				if labelrow[y]
					decreaseheight = decreaseheight + panelRowHeight - labelrow[y]
				else if navrow[y]
					decreaseheight = decreaseheight + panelRowHeight - navrow[y]
		return decreaseheight