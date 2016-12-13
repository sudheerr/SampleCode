Ext.define 'Corefw.view.form.field.ChartField',
	extend: 'Ext.form.FieldContainer'
	mixins: ['Corefw.mixin.CoreField']
	xtype: 'corechartfield'

	frame: false
	coretype: 'field'

	candidateColors:[]

	convertHEXRGB2Arr:(hexRGB)->
		return  [parseInt("0x"+hexRGB.substr(1,2)),parseInt("0x"+hexRGB.substr(3,2)),parseInt("0x"+hexRGB.substr(5,2))]

	getCandidateColors:(seriesNum=1)->
		repeatTime =Math.ceil(  seriesNum/@candidateColors.length)
		ret=[]
		while repeatTime!=0
#		    convert [1,2,3]to rgba(1,2,3,alpha)format  alpha=(1-(repeatTime-1)*0.2)
			arr = ("rgba("+rgbArr.join(',')+","+(1-(repeatTime-1)*0.2)+")" for rgbArr in @candidateColors)
			ret=arr.concat(ret)
			repeatTime=repeatTime-1
		ret

	convertColors:->
		colors=['#4caeed','#ff944c','#4ca977','#e54343','#a7a5a6',"#43E622","#002d72","#0ACED8","#c6007e","#a05eb5","#ffcd00","#ff2900","#b4975a" ,"#53565a"]
		@candidateColors = (@convertHEXRGB2Arr color  for color in colors)


	initComponent: ->
		@convertColors()
		cm = Corefw.util.Common
		#de = Corefw.util.Debug
		rdr = Corefw.util.Render
		evt = Corefw.util.Event
		su = Corefw.util.Startup

		# default layout, can be overriden
		@layout = 'fit'

		cache = @cache
		props = cache._myProperties
		@uipath = props.uipath
		# if de.printOutGridFields()
		# 	console.log ' -> -> ->', cache._myProperties.name, cache

		cacheSeries = props.columnAr
		if cacheSeries.length
			for oneSeries in cacheSeries
				if oneSeries?._myProperties?.visible
					firstSeries = oneSeries._myProperties
					break
		else
			# no series defined, quit right now
			console.error 'ERROR: no chart series defined, ignoring this chart'
			return

		# we'll drive the entire chart type off the first series
		if not firstSeries
			firstSeries = {seriesType: 'line'}
		chartType = firstSeries.seriesType?.toLowerCase()

		supportedChartTypes = ['column', 'line', 'area', 'bar', 'pie']

		if chartType not in supportedChartTypes
			# chart type not supported
			console.error "ERROR: chart type #{chartType} not yet supported, ignoring this chart"
			return

		# create cross reference of pathString to title
		dataIndexToTitle = {}
		props.dataIndexToTitle = dataIndexToTitle

		# create the array of fields
		leftFieldAr = []
		rightFieldAr = []

		@leftFieldAr = leftFieldAr
		@rightFieldAr = rightFieldAr

		for oneCol in cacheSeries
			fieldProps = oneCol._myProperties

			if fieldProps.visible
				pathString = fieldProps.pathString
				axisPosition = fieldProps.axis
				if axisPosition.toLowerCase() is 'right'
					rightFieldAr.push pathString
					@rightAxisFormat = fieldProps.format if fieldProps.format
				else
					leftFieldAr.push pathString
					@leftAxisFormat = fieldProps.format if fieldProps.format
				@fieldFormat = fieldProps.format if fieldProps.format
				dataIndexToTitle[pathString] = fieldProps.title
		if 'axesConfig' of props
			axesConfig = props.axesConfig
			@leftAxisFormat = axesConfig.premaryYAxisConfig if axesConfig.premaryYAxisConfig
			@rightAxisFormat = axesConfig.secondaryYAxisConfig if axesConfig.secondaryYAxisConfig
		@isRenderRightAxis = rightFieldAr.length > 0
		storeName = @uipath + '/Store'
		st = @createStore storeName, props.series, props

		sortedCacheSeries = @sortSeries cacheSeries

		if chartType is 'pie'
			[ seriesAr, axesAr ] = @configPolarNew()
		else
			[ seriesAr, axesAr ] = @configCartesianNew sortedCacheSeries

		legendPosition = false
		if cache._myProperties.legend
			alignLegend = cache._myProperties.alignLegend.toLowerCase()
			if alignLegend isnt 'none'
				legendPosition = alignLegend

		config =
			margin: 10
			store: st
			series: seriesAr
			axes: axesAr
			theme: 'CVCustom'
			legend: false
			legendPosition: legendPosition
			flex: 1

		if su.getThemeVersion() is 2
			config.style = 'backgroundColor: #EBEBEB;'
			config.margin = 0
			config.insetPadding = 15

		comp = Ext.create 'Ext.chart.Chart', config
		@chart = comp
		if chartType is 'column'
			@updateThemeAttrsColors @chart, sortedCacheSeries

		# check to see if any navs are defined for the chart
		navAr = props?.navs?._ar
		if navAr
			toolbarAr = []

			for nav in navAr
				navObj =
					uipath: nav.uipath
					hidden: not nav.visible
					disabled: not nav.enabled
					name: nav.name
					margin: '0 0 0 3'
					xtype: 'button' #///changed the look and feel according to UX guidelines///*
					ui: 'toolbutton'
					scale: 'small'

				tbLayout =
					type: 'hbox'

				switch nav.align
					when 'CENTER'
						tbLayout.pack = 'center'
					when 'RIGHT'
						tbLayout.pack = 'end'
					else
						tbLayout.pack = 'start'

				if nav.toolTip
					navObj.tooltip = nav.toolTip

				if nav.style
					navObj.iconCls = nav.style

				toolbarAr.push navObj
				evt.addEvents nav, 'nav', navObj

			toolbar = Ext.create 'Ext.Container',
				layout: tbLayout
				items: toolbarAr

			@layout =
				type: 'vbox'
				align: 'stretch'

			@items = [ toolbar, comp ]
		else
			@items = [ comp ]

		delete @fieldAr
		@callParent arguments

		me = this
		# set parent element
		myFunc = Ext.Function.createDelayed ->
			elemComp = me.up '[coretype=element]'
			me.element = elemComp
			return
		, 1
		myFunc()

		return

	sortSeries: (cacheSeries) ->
		series = []
		columnSeries = []
		lineSeries = []
		otherSeries = []

		for seriesObj in cacheSeries
			seriesProps = seriesObj._myProperties
			if seriesProps.seriesType is 'COLUMN' and seriesProps.visible
				columnSeries.push seriesObj
			else if seriesProps.seriesType is 'LINE' and seriesProps.visible
				lineSeries.push seriesObj
			else
				otherSeries.push seriesObj

		series = columnSeries.concat lineSeries
		series = series.concat otherSeries


	updateThemeAttrsColors: (chart, cacheSeries) ->
		if chart.theme is 'CVCustom'
			chart.themeAttrs.colors = @getCandidateColors(cacheSeries.length)
		themeAttrsColors = chart.themeAttrs.colors
		index = 0
		for oneSeries in cacheSeries
			if not Ext.isEmpty oneSeries._myProperties.color
				themeAttrsColors[index] = oneSeries._myProperties.color
			index = index + 1
		return

	configCartesianNew: (series) ->
		me = this
		su = Corefw.util.Startup
		props = @cache._myProperties
		dataIndexToTitle = props.dataIndexToTitle

		seriesAr = []
		axesAr = []

		#Adding y-axis title(Left/Right) for the chart.
		for oneCol in series
			if oneCol._myProperties.visible
				axis = oneCol._myProperties?.axis.toLowerCase()
				axisTitle = oneCol._myProperties?.yaxisTitle
				if axisTitle.length > 0
					if axis is 'right'
						yRightAxisTitle = axisTitle
					else
						yLeftAxisTitle = axisTitle

		# separate setting left and right axis
		leftNumAxis =
			type: 'Numeric'
			grid: true
			position: 'left'
			fields: @leftFieldAr
			title: yLeftAxisTitle

		if @leftAxisFormat
			leftNumAxis.label =
				renderer: Ext.util.Format.numberRenderer @leftAxisFormat

		if @isRenderRightAxis
			rightNumAxis =
				type: 'Numeric'
				grid: true
				position: 'right'
				fields: @rightFieldAr
				title: yRightAxisTitle


			if @rightAxisFormat
				rightNumAxis.label =
					renderer: Ext.util.Format.numberRenderer @rightAxisFormat

		labelAxis =
			type: 'Category'
			position: 'bottom'
			fields: [
				props.groupBy
			]


		if props.labelRotated
			label =
				rotate:
					degrees:
						315
			labelAxis.label = label

		if props.xLabelTransfer
			me.xLabelTransfer = props.xLabelTransfer
			rendererFunction = (value) ->
				if me.xLabelTransfer[value]
					return me.xLabelTransfer[value]
				else
					return ''
			if Ext.isEmpty label
				label =
					renderer: rendererFunction
			else
				label.renderer = rendererFunction

		if su.getThemeVersion() is 2
			labelAxis.label =
			leftNumAxis.label =
				fill: '#2B2B2B'
			if rightNumAxis
				rightNumAxis.label =
					fill: '#2B2B2B'

		chartType = series[0]?._myProperties?.seriesType?.toLowerCase()
		if chartType is 'bar'
			# set axes to horizontal
			if @isRenderRightAxis
				leftNumAxis.position = 'top'
				rightNumAxis.position = 'bottom'
			else
				leftNumAxis.position = 'bottom'
			labelAxis.position = 'left'

		if props.xAxisTitle
			labelAxis.title = props.xAxisTitle

		axesAr.push leftNumAxis
		axesAr.push rightNumAxis if @isRenderRightAxis
		axesAr.push labelAxis

		# set the series
		# holds array of series, indexed by type
		# each series type has its own array
		seriesType = {}

		configSeriesStyle = (currentColprops) ->
			styleObj = {}
			if currentColprops.color isnt ''
				styleObj.stroke = currentColprops.color
			if currentColprops.lineWidth
				styleObj['stroke-width'] = currentColprops.lineWidth
			styleObj.radius = currentColprops.radius
			return styleObj

		styleObjs = {}
		for oneCol in series
			colprops = oneCol?._myProperties
			if colprops?.isRemovedFromUI or not colprops?.visible
				continue
			chartType = colprops.seriesType?.toLowerCase()
			axisType = colprops.axis
			chartTypeAxis = chartType + '-' + axisType
			styleObj = configSeriesStyle colprops

			typeAr = seriesType[chartTypeAxis]
			if not typeAr
				typeAr = []
				seriesType[chartTypeAxis] = typeAr
			path = colprops.pathString
			styleObjs[path] = styleObj

			typeAr.push path

		me = this
		# set a single series here
		setCartesianSeries = (currentChartType, currentAxis, typeAr2, currentStyleObj) ->
			seriesObj =
				type: currentChartType
				xField: props.groupBy
				yField: typeAr2
				stacked: false
				highlight: true
				style:
        	lineWidth: 0

			if currentChartType is 'line'
				seriesObj.markerConfig =
					type: 'circle'
					radius: currentStyleObj.radius
				seriesObj.highlight =
					radius: currentStyleObj.radius + 2

				if currentStyleObj and currentStyleObj.stroke isnt ''
					seriesObj.markerConfig.fill = currentStyleObj.stroke
				seriesObj.style = currentStyleObj

			if typeAr2 and typeAr2.length
				seriesObj.tips =
					trackMouse: true
					shrinkWrapDock: true
					renderer: (storeItem, item) ->
						if typeAr2.length is 1
							bodyTextField = typeAr2[0]
						else
							bodyTextField = if item.yField then item.yField else item.storeField
						@setTitle storeItem.get props.groupBy
						@update Ext.util.Format.number(storeItem.get(bodyTextField), me.fieldFormat)
						return

				seriesObj.title = []
				for fieldPath in typeAr2
					seriesObj.title.push dataIndexToTitle[fieldPath]

			if me.eventURLs?.ONCLICK
				seriesObj.listeners =
					itemclick:
						fn: me.segmentItemClick
						scope: me

			if currentChartType is 'bar'
				seriesObj.axis = 'bottom'
			else
				seriesObj.axis = currentAxis.toLowerCase()
			if seriesObj.type is 'area' or props.stacked
				seriesObj.stacked = true

			seriesAr.push seriesObj
			return



		for chartTypeAxis, typeAr of seriesType
			[chartType, axis] = chartTypeAxis.split '-'

			if chartType is 'line'
				# all line fields must be listed as a separate series
				for oneCol in typeAr
					found = false
					styleObj = styleObjs[oneCol]

					cache = @cache
					props = cache._myProperties

					cacheSeries = props.columnAr
					if cacheSeries.length
						for oneSeries in cacheSeries
							if oneSeries?._myProperties?.pathString is axis and not oneSeries?._myProperties?.visible
								found = true
								break
					if found
						setCartesianSeries chartType, axis, null, styleObj
					else
						setCartesianSeries chartType, axis, [oneCol], styleObj
			else
				# otherwise, set the yField to the array for that type
				setCartesianSeries chartType, axis, typeAr

		return [ seriesAr, axesAr ]



	# return type: seriesAr, axesAr
	# polar doesn't explicitly define axes
	configPolarNew: ->
		props = @cache._myProperties
		series = props.columnAr
		seriesAr = []
		su = Corefw.util.Startup

		# only 1 display set is valid for pie chart
		seriesProps = series[0]._myProperties
		seriesType = seriesProps.seriesType?.toLowerCase()

		path = seriesProps.pathString

		seriesObj =
			type: seriesType
			angleField: path
			showInLegend: true
			highlight:
				segment:
					margin: 20
			label:
				field: props.groupBy
				display: 'rotate'
				contrast: true
				renderer: (value, label, storeItem) ->
					if su.getThemeVersion() is 2
						if props.showAs
							if props.showAs in ['PERCENTAGE', 'DEFAULT']
								total = 0
								storeItem.store.each (rec) ->
									total += rec.get path
									return
								value = if total isnt 0 then Math.round(storeItem.get(path) / total * 100) + '%' else ''
							else if props.showAs is 'NUMBER'
								value = storeItem.get(path)
							else if props.showAs is 'NONE'
								label.el.setVisible false
							else
								value = value
					return value
			tips:
				trackMouse: true
				shrinkWrapDock: true
				renderer: (storeItem, item) ->
					total = 0
					storeItem.store.each (rec) ->
						total += rec.get path
						return
					@setTitle storeItem.get(props.groupBy) + if total isnt 0 then ': ' + Math.round(storeItem.get(path) / total * 100) + '%' else ''
					@update storeItem.get path
					return
		# Adding custom display & colors to pie chart
		if su.getThemeVersion() is 2
			seriesObj.label.display = 'outside'
			if props.textDisplayStyle
				textDisplay = props.textDisplayStyle.toLowerCase()
				if props.textDisplayStyle is 'HORIZONTAL'
					textDisplay = 'middle'
				seriesObj.label.display = textDisplay

			if props.chartColors and props.chartColors.length
				chartColorSet = Ext.Array.map props.chartColors, (colors) ->
					return Corefw.util.Cache.chartColorsSet[colors]
				seriesObj.colorSet = chartColorSet

			seriesObj.style =
				stroke: '#EBEBEB'
				'stroke-width': 2
			seriesObj.shadowAttributes = []
			seriesObj.label.contrast = false
			seriesObj.label.padding = 0
			seriesObj.label.color = '#2B2B2B'
			seriesObj.highlight.segment.margin = 4

		me = this
		if me.eventURLs?.ONCLICK
			seriesObj.listeners =
				itemclick:
					fn: me.segmentItemClick
					scope: me

		seriesAr.push seriesObj
		return [ seriesAr, [] ]

	# in the cache, inputAr points to cache._myProperties.data.items
	createStore: (name, inputAr, chartProps) ->
		cm = Corefw.util.Common
		storeDataAr = []
		fields = []
		storeConfig =
			autoDestroy: true
			autoLoad: true
			fields: fields
			storeId: name
			data: storeDataAr

		if inputAr and Ext.isArray(inputAr) and inputAr.length
			# define the fields with the 1st row
			firstRowObj = inputAr[0]
			for key, fieldValue of firstRowObj
				# add colObj here
				storeFieldObj =
					name: key
					type: cm.valueToFieldType fieldValue

				fields.push storeFieldObj

			index = 0
			for valueObj in inputAr
				# this is a key/value object representing the entire row
				# we need to go through each value one at a time to see if conversion is necessary

				for path, colValue of valueObj
					if Ext.isDate colValue
						dt = new Date colValue
						valueObj[path] = dt
						continue

				storeDataAr.push valueObj

		Corefw.util.Data.removeStore name
		st = Ext.create 'Ext.data.Store', storeConfig
		return st


	segmentItemClick: (obj, eOpts) ->
		rq = Corefw.util.Request
		chart = eOpts.scope
		console.log 'segement item click: item, chart, uipath: ', obj, chart, @uipath
		url = rq.objsToUrl3 chart.eventURLs.ONCLICK
		postData = @generatePostData obj
		console.log '%% postData ', postData
		rq.sendRequest5 url, rq.processResponseObject, @uipath, postData
		return



	generatePostData: (selectedObj) ->
		cache = @cache
		props = cache._myProperties
		postData =
			name: props.name

		if not selectedObj
			return postData

		# for pie chart
		seriesName = selectedObj.series?.angleField
		if not seriesName
			# for cartesian charts
			seriesName = selectedObj.yField
			if not seriesName
				# for area charts
				seriesName = selectedObj.storeField

		# cartesian charts / area charts
		labelField = selectedObj.series?.xField
		if not labelField
			# pie charts
			labelField = selectedObj.series?.label?.field

		model = selectedObj.storeItem

		if labelField and model
			segmentValue = model.get labelField

		console.log 'generatePostData: selectedObj, seriesName, segmentValue, labelField, model: ', selectedObj, seriesName, segmentValue, labelField, model

		if seriesName and segmentValue
			selectedSegment =
				seriesName: seriesName
				segmentValue: segmentValue

			postData.selectedSegment = selectedSegment

		return postData