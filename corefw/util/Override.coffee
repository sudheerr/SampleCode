Ext.define 'Corefw.util.Override',
	singleton: true

	numberOverride: ->
		#Override for negative number format bug
		#http://www.sencha.com/forum/showthread.php?265856-Ext.util.Format.number-and-negative-numbers
		Ext.util.Format.formatFns = {}
		Ext.util.Format.number = (v, formatString) ->
			test = parseInt(v) or parseFloat(v)
			# do nothing if v is string could not be parsed to number
			return v if isNaN test
			stripTagsRE = /<\/?[^>]+>/g
			stripScriptsRe = /(?:<script.*?>)((\n|\r|.)*?)(?:<\/script>)/g
			nl2brRe = /\r?\n/g
			allHashes = /^#+$/
			formatPattern = /[\d,\.#]+/
			formatCleanRe = /[^\d\.#]/g
			return v  unless formatString
			formatFn = Ext.util.Format.formatFns[formatString]
			unless formatFn
				originalFormatString = formatString
				comma = Ext.util.Format.thousandSeparator
				decimalSeparator = Ext.util.Format.decimalSeparator
				precision = 0
				if formatString.substr(formatString.length - 2) is "/i"
					I18NFormatCleanRe = new RegExp("[^\\d\\" + Ext.util.Format.decimalSeparator + "]", "g")
					formatString = formatString.substr(0, formatString.length - 2)
					hasComma = formatString.indexOf(comma) isnt -1
					splitFormat = formatString.replace(I18NFormatCleanRe, "").split(decimalSeparator)
				else
					hasComma = formatString.indexOf(",") isnt -1
					splitFormat = formatString.replace(formatCleanRe, "").split(".")
				extraChars = formatString.replace(formatPattern, "")
				if splitFormat.length > 2
					Ext.Error.raise
						sourceClass: "Ext.util.Format"
						sourceMethod: "number"
						value: v
						formatString: formatString
						msg: "Invalid number format, should have no more than 1 decimal"

				else if splitFormat.length is 2
					precision = splitFormat[1].length

					# Formatting ending in .##### means maximum 5 trailing significant digits
					trimTrailingZeroes = allHashes.test(splitFormat[1])

				# The function we create is called immediately and returns a closure which has access to vars and some fixed values; RegExes and the format string.
				code = [
				  "var utilFormat=Ext.util.Format,extNumber=Ext.Number,neg,absVal,fnum,parts" + ((if hasComma then ",thousandSeparator,thousands=[],j,n,i" else "")) + ((if extraChars then ",formatString=\"" + formatString + "\",formatPattern=/[\\d,\\.#]+/" else "")) + ((if trimTrailingZeroes then ",trailingZeroes=/\\.?0+$/;" else ";")) + "return function(v){" + "if(typeof v!==\"number\"&&isNaN(v=extNumber.from(v,NaN)))return\"\";" + "neg=v<0;"
				  "absVal=Math.abs(v);"
				  "fnum=Ext.Number.toFixed(absVal, " + precision + ");"
				]
				if hasComma
					if precision
						code[code.length] = "parts=fnum.split(\".\");"
						code[code.length] = "fnum=parts[0];"
					code[code.length] = "if(absVal>=1000) {"
					code[code.length] = "thousandSeparator=utilFormat.thousandSeparator;" + "thousands.length=0;" + "j=fnum.length;" + "n=fnum.length%3||3;" + "for(i=0;i<j;i+=n){" + "if(i!==0){" + "n=3;" + "}" + "thousands[thousands.length]=fnum.substr(i,n);" + "}" + "fnum=thousands.join(thousandSeparator);" + "}"
					code[code.length] = "fnum += utilFormat.decimalSeparator+parts[1];"  if precision

				# If they are using a weird decimal separator, split and concat using it
				else code[code.length] = "if(utilFormat.decimalSeparator!==\".\"){" + "parts=fnum.split(\".\");" + "fnum=parts[0]+utilFormat.decimalSeparator+parts[1];" + "}"  if precision
				code[code.length] = "fnum=fnum.replace(trailingZeroes,\"\");"  if trimTrailingZeroes
				code[code.length] = "if(neg&&fnum!==\"" + ((if precision then "0." + Ext.String.repeat("0", precision) else "0")) + "\")fnum=\"-\"+fnum;"
				code[code.length] = "return "
				if extraChars
					code[code.length] = "formatString.replace(formatPattern, fnum);"
				else
					code[code.length] = "fnum;"
				code[code.length] = "};"
				formatFn = Ext.util.Format.formatFns[originalFormatString] = Ext.functionFactory("Ext", code.join(""))(Ext)
			formatFn v

		#Completed -- Override for negative number format bug

	# patching the Ext object for IE11 support
	ie11Override: ->
		ext = Ext 		# store in local variable for faster access
		check = (regex) ->
			return regex.test Ext.userAgent

		docMode = parseInt document.documentMode

		ext.isIE = !ext.isOpera and (check(/msie/) or check(/trident/))
		ext.isIE11 = ext.isIE and ((check(/trident\/7\.0/) and docMode isnt 7 and docMode isnt 8 and docMode isnt 9 and docMode isnt 10) or docMode is 11)
		ext.isGecko = !ext.isWebKit and !ext.isIE and check(/gecko/)        # IE11 adds "like gecko" into the user agent string

		# True if the detected browser is Internet Explorer 11.x or lower.
		ext.isIE11m = ext.isIE6 or ext.isIE7 or ext.isIE8 or ext.isIE9 or ext.isIE10 or ext.isIE11

		# True if the detected browser is Internet Explorer 11.x or higher.
		ext.isIE11p = ext.isIE and !(ext.isIE6 or ext.isIE7 or ext.isIE8 or ext.isIE9 or ext.isIE10)

		ext.isIE10p = ext.isIE and !(ext.isIE6 or ext.isIE7 or ext.isIE8 or ext.isIE9)
		return

	# Custom colors for charts defined by UX standards
	customColors: ->
		colors = ['#4caeed','#ff944c', '#4ca977', '#e54343', '#a7a5a6', '#f7c54d', '#976ea0', '#ff694c', '#00b0b9','#4C6C9C','#53565a','#99abc7']
		themes = Ext.chart.theme;
		themes['CVCustom'] = do (colors) ->
			 Ext.extend themes.Base, constructor: (config) ->
			 	 themes.Base::constructor.call this, Ext.apply({ colors: colors }, config)
			 	 return
		return;


	# various hacks to get this thing to work with IE
	# this gets called BEFORE @launch
	workarounds: ->
		@numberOverride()
		@ie11Override()
		@customColors()

		# shim for console.log
		if not window.console
			window.console =
				log: ->

		if Ext.isIE10p
		 	console.log 'running in IE10p'
		 	Ext.supports.Direct2DBug = true

		if Ext.isIE8
			console.log 'running in IE8'

			# bug in IE8 setStyle
			# this is a hack to fix it
			# not sure if it's a Sencha CSS bug, or a bug in our CSS code
			# see http://www.sencha.com/forum/showthread.php?281674-ExtJs4-IE8-getting-invalid-argument-error-(on-call-to-setStyle)
			#       on Sencha forums

			Ext.override Ext.dom.Element,
				setStyle: (prop, value) ->
					fixBadValue = (val) ->
						result = val
						re = new RegExp /NaNpx/ig

						if val
							if val.search
								if val.search(re) > -1
									result = 'inherit'
						return result

					_prop = prop
					_value = fixBadValue value

					if _prop
						for key, badprop of _prop
							_prop[key] = fixBadValue badprop

					return this.callSuper [_prop, _value]

		return

	#NOTICE : this method should be called after the startJson is set to Startup.js
	#workarounds for latest theme
	# For Date Picker, Day names has to show two letters instead of one letter(Su, Mo, Tu,..)
	workaroundsForNewTheme: ->	
		su = Corefw.util.Startup
		if su.getThemeVersion() is 2
			Ext.override Ext.picker.Date, 
				getDayInitial:(value)->
					return value.substr 0,2
		return

	columnComponentLayoutOverride: ->
		# we have inline filter in column header, hack the column component layout method to fix render issue. Behavior is always the same with prototype version.
		Ext.override Ext.grid.ColumnComponentLayout,
			publishInnerHeight: (ownerContext, outerHeight) ->
				if not outerHeight
					return
				that = @
				owner = that.owner
				cmp = Ext.getCmp ownerContext.id
				inlineFilterOffset = 0
				if cmp?.filter?.inlineFilter
					inlineFilterOffset = cmp.filter.filterWidget.getHeight()
				innerHeight = outerHeight - ownerContext.getBorderInfo().height - inlineFilterOffset
				availableHeight = innerHeight

				if not owner.noWrap and not ownerContext.hasDomProp 'width'
					that.done = false
					return

				if ownerContext.hasRawContent
					titleHeight = availableHeight
					textHeight = owner.textEl.getHeight()
					if textHeight
						availableHeight -= textHeight
						if availableHeight >0
							pt = Math.floor availableHeight / 2
							pb = availableHeight - pt
							ownerContext.titleContext.setProp 'padding-top', pt
							ownerContext.titleContext.setProp 'padding-bottom', pb

				else
					titleHeight = owner.titleEl.getHeight()
					ownerContext.setProp 'innerHeight', innerHeight - titleHeight, false

				return
			calculateOwnerWidthFromContentWidth: (ownerContext, contentWidth) ->
				owner = @owner
				triggerOffset = this.getTriggerOffset owner, ownerContext
				if owner.bugfixfromext5 and owner.isGroupHeader
					return contentWidth + ownerContext.getPaddingInfo().width + triggerOffset
				return @callParent arguments
		return

	#	override getMaxContentWidth to fix 1px issue
	columnGetMaxContentWidthOverride:->
		Ext.override Ext.view.Table,getMaxContentWidth:(header)->
			me = @
			cells = me.el.query header.getCellInnerSelector()
			originalWidth = header.getWidth()
			ln = cells.length
			hasPaddingBug = Ext.supports.ScrollWidthInlinePaddingBug
			columnSizer = me.body.select me.getColumnSizerSelector header
			max = Math.max

			if hasPaddingBug and ln > 0
				paddingAdjust = me.getCellPaddingAfter cells[0]


			# Set column width to 1px so we can detect the content width by measuring scrollWidth
			columnSizer.setWidth 1

			# Allow for padding round text of header
			maxWidth = originalMaxWidth = header.textEl.dom.offsetWidth + header.titleEl.getPadding 'lr'
			for i in [0 .. ln-1]
				maxWidth = max(maxWidth, cells[i].scrollWidth);

			if hasPaddingBug
				# in some browsers, the "after" padding is not accounted for in the scrollWidth
				maxWidth += paddingAdjust

			# 40 is the minimum column width.
			maxWidth = max maxWidth, 40

			# add 1px to fix issue
			if originalMaxWidth isnt maxWidth
				maxWidth++

			# Set column width back to original width
			columnSizer.setWidth(originalWidth);

			return maxWidth;

	# override to provide XHR information (mainly for selenium test)
	xhrStatusOverride: ->
		Ext.data.Connection.addStatics
			xhrStatusCache: {}
			findXhrStatus: (statusList, urlParams, exact=false)->
				if not urlParams or (!exact and Ext.Object.getSize(urlParams) is 0)
					return statusList
				match = []
				for statusItem in statusList
					if exact
						if statusItem?.params and Ext.encode(statusItem.params) is Ext.encode(urlParams)
							match.push statusItem
							break
					else
						if statusItem?.params and Ext.encode(statusItem.params).indexOf(Ext.encode(urlParams).slice(1,-1))>-1
							match.push statusItem
				return match
			setXhrStatus: (options, status, exact)->
				if options?.url
					urlParts = Corefw.util.Request.getShortUrl(options.url).split "&"
					eventURL = urlParts[0]
					urlParams = {}
					urlParts.slice(1).forEach (v)->
						[pk, pv] = v.split("=")
						urlParams[pk] = decodeURI pv
					method = options.method ? "POST"
					data = 
						status: status
						params: urlParams
					Ext.data.Connection.xhrStatusCache[method] ?= {}
					Ext.data.Connection.xhrStatusCache[method][eventURL] ?= []
					matches = Ext.data.Connection.findXhrStatus Ext.data.Connection.xhrStatusCache[method][eventURL], urlParams, exact
					if matches.length > 0
						for match in matches
							match.status = status
					else
						Ext.data.Connection.xhrStatusCache[method][eventURL].push data
			getXhrStatus: (eventURL, method="POST", urlParams)->
				statusList = Ext.data.Connection.xhrStatusCache?[method]?[eventURL] ? []
				matches = Ext.data.Connection.findXhrStatus statusList, urlParams
				return matches?[0]?.status ? "na"
			xhrInitiate: (options, exact=false)->
				Ext.data.Connection.setXhrStatus options, "initial", exact
			xhrComplete: (options, exact=false)->
				Ext.data.Connection.setXhrStatus options, "complete", exact
			isXhrCompleted: (eventURL, method, urlParams)->
				"complete" is Ext.data.Connection.getXhrStatus eventURL, method, urlParams

		Ext.override Ext.data.Connection, request: (options)->
			me = @
			try
				Ext.data.Connection.xhrInitiate options, true
			catch e
				console.error "Error on setting xhr status(request): ", e
			return me.callParent arguments

		Ext.override Ext.data.Connection, onComplete: (request)->
			me = @
			ret = me.callParent arguments
			try
				Ext.data.Connection.xhrComplete request?.options, true
			catch e
				console.error "Error on setting xhr status(onComplete): ", e
			return ret
			
	# Override the algorithm of label height, ext will minus the error message height when calculate the inputEl height
	# (msgTarget: under)
	measureLabelErrorHeightOverride: ->
		Ext.override Ext.layout.component.field.Field,
			measureLabelErrorHeight: (ownerContext) ->
				su = Corefw.util.Startup
				if su.getThemeVersion() is 2 and ownerContext.target.msgTarget is 'under'
					ownerContext.labelStrategy.getHeight(ownerContext)
				else
					ownerContext.labelStrategy.getHeight(ownerContext) + ownerContext.errorStrategy.getHeight(ownerContext)

	# to provide better support for label/legend
	pieChartEnhancementOverride: ->
		Ext.override Ext.ux.chart.SmartLegend,
			getBBox: ->
				p = this.callParent arguments
				p.width = 0 if p.width < 0
				p.height = 0 if p.height < 0
				return p
			,calcPosition: ->
				me = this
				p = me.callParent arguments
				switch me.position
					when 'bottom'
						p.y += me.getChartInsets().bottom
				return p
		Ext.override Ext.chart.Chart, 
			calculateInsets: ->
				me = this
				legend = me.legend
				axes = me.axes
				edges = ['top', 'right', 'bottom', 'left']
				getAxis = (edge) ->
					i = axes.findIndex 'position', edge
					return if i < 0 then null else axes.getAt(i)				
				insets = me.getInsets()
				for edge in edges
					isVertical = edge in ['left', 'right']
					axis = getAxis edge
					if legend isnt false
						if legend.position is edge
							bbox = legend.getBBox()
							insets[edge] += if isVertical then bbox.width else bbox.height
					if axis and axis.bbox
						bbox = axis.bbox
						insets[edge] += if isVertical then bbox.width else bbox.height
				return insets
		# below code is from ExtJS4.2.2, aim to add padding for 'outside' label, could be removed after upgrade EXTJS
		Ext.override Ext.draw.Draw,
			normalizeDegrees: (degrees) ->
				if degrees >= 0
					return degrees % 360
				return ((degrees % 360) + 360) % 360
		Ext.override Ext.chart.series.Pie,
			setSpriteAttributes: (sprite, attrs, animate) ->
				me = this;
				if animate
					sprite.stopAnimation();
					sprite.animate
						to: attrs
						duration: me.highlightDuration
				else
					sprite.setAttributes attrs, true
			,highlightItem: (item) ->
				me = this
				rad = me.rad
				item = item or this.items[this._index]
				this.unHighlightItem()
				if not item or me.animating or (item.sprite and item.sprite._animating)
					return
				me.callSuper [item]
				if not me.highlight
					return
				if 'segment' of item.series.highlight
					highlightSegment = item.series.highlight.segment
					animate = me.chart.animate
					if me.labelsGroup
						group = me.labelsGroup
						display = me.label.display
						label = group.getAt(item.index)
						middle = (item.startAngle + item.endAngle) / 2 * rad
						r = highlightSegment.margin or 0
						x = r * Math.cos(middle)
						y = r * Math.sin(middle)
						if Math.abs(x) < 1e-10
							x = 0
						if Math.abs(y) < 1e-10
							y = 0
						me.setSpriteAttributes label, { translate: {x:x, y:y}}, animate
						line = label.lineSprite
						if line
							me.setSpriteAttributes line, { translate: {x:x, y:y}}, animate
					if me.chart.shadow and item.shadows
						for shadow in item.shadows
							to = {}
							itemHighlightSegment = item.sprite._from.segment
							for prop in itemHighlightSegment
								if not (prop of highlightSegment)
									to[prop] = itemHighlightSegment[prop]
							attrs = segment: Ext.applyIf(to, me.highlightCfg.segment)
							me.setSpriteAttributes shadow, attrs, animate
			,onPlaceLabel: (label, storeItem, item, i, display, animate, index) ->
				me = this
				chart = me.chart
				resizing = chart.resizing
				config = me.label
				format = config.renderer
				field = config.field
				centerX = me.centerX
				centerY = me.centerY
				middle = item.middle
				opt =
				    x: middle.x
				    y: middle.y
				x = middle.x - centerX
				y = middle.y - centerY
				from = {}
				rho = 1
				theta = Math.atan2(y, x or 1)
				dg = Ext.draw.Draw.degrees(theta)
				isOutside = (display is 'outside')
				calloutLine = label.attr.calloutLine
				lineWidth = (calloutLine and calloutLine.width) or 2
				labelPadding = label.attr.padding ? 20
				labelPadding += if isOutside then lineWidth/2 else 0
				labelPaddingX = 0
				labelPaddingY = 0
				opt.hidden = false
				if this.__excludes && this.__excludes[i]
					opt.hidden = true
				label.setAttributes
					opacity: if opt.hidden then 0 else 1
					text: format(storeItem.get(field), label, storeItem, item, i, display, animate, index)
				, true
				if label.lineSprite
					attrs = { opacity: if opt.hidden then 0 else 1 }
					if opt.hidden
						attrs.translate = {x:0, y:0}
					me.setSpriteAttributes(label.lineSprite, attrs, false)
				switch display
					when 'outside'
						label.isOutside = true
						rho = item.endRho
						labelPaddingX = if Math.abs(dg) <= 90 then labelPadding else -labelPadding
						labelPaddingY = if dg >= 0 then labelPadding else -labelPadding
						label.setAttributes rotation:degrees: 0, true
						labelBox = label.getBBox()
						width = labelBox.width/2 * Math.cos(theta)
						height = labelBox.height/2 * Math.sin(theta)
						width += labelPaddingX
						height += labelPaddingY
						rho += Math.sqrt(width*width + height*height)
						opt.x = rho * Math.cos(theta) + centerX
						opt.y = rho * Math.sin(theta) + centerY	
					when 'rotate'
						dg = Ext.draw.Draw.normalizeDegrees dg
						dg = if dg > 90 and dg < 270 then dg + 180 else dg
						prevDg = label.attr.rotation.degrees
						if prevDg isnt null and Math.abs(prevDg - dg) > 180 * 0.5
							if (dg > prevDg)
								dg -= 360
							else
								dg += 360
							dg = dg % 360
						else
							dg = Ext.draw.Draw.normalizeDegrees dg
						opt.rotate =
							degrees: dg
							x: opt.x
							y: opt.y
				opt.translate =
					x: 0
					y: 0
				if animate and not resizing and (display isnt 'rotate' or prevDg isnt null)
					me.onAnimate label,
						to: opt
				else
					label.setAttributes opt, true
				label._from = from
				if label.isOutside and calloutLine
					line = label.lineSprite
					animateLine = animate
					fromPoint =
						x: (item.endRho - lineWidth/2) * Math.cos(theta) + centerX
						y: (item.endRho - lineWidth/2) * Math.sin(theta) + centerY
					labelCenter =
						x: opt.x
						y: opt.y
					toPoint = {}
					sign = (x)->
						if x
							return if x < 0 then -1 else 1
						return 0
					if calloutLine and calloutLine.length
						toPoint =
							x: (item.endRho + calloutLine.length) * Math.cos(theta) + centerX
							y: (item.endRho + calloutLine.length) * Math.sin(theta) + centerY
					else
						normalTheta = Ext.draw.Draw.normalizeRadians(-theta)
						cos = Math.cos(normalTheta)
						sin = Math.sin(normalTheta)
						labelWidth = (labelBox.width + lineWidth + 4)/2
						labelHeight = (labelBox.height + lineWidth + 4)/2
						if Math.abs(cos) * labelHeight > Math.abs(sin) * labelWidth
							toPoint.x = labelCenter.x - labelWidth * sign(cos)
							toPoint.y = labelCenter.y + labelWidth * sin/cos * sign(cos)
						else
							toPoint.x = labelCenter.x - labelHeight * cos/sin * sign(sin)
							toPoint.y = labelCenter.y + labelHeight * sign(sin)
					if not line
						line = label.lineSprite = me.createLabelLine(i)
						animateLine = false
					me.drawLabelLine label, fromPoint, toPoint, animateLine
				else
					delete label.lineSprite

	rowModelOverride: ->
		return
		Ext.override Ext.selection.RowModel,
			isRowSelected: (record, index) ->
				try
					if Ext.isNumber record
						totalCount = @store.totalCount
						return false if record >= totalCount
					return @isSelected record
				catch err
					return false

	gridHeaderReordererPluginOverride: ->
		# To disable dragging process if current header is trying to out of its group header
		overrideBeforeDragOver = (target, e) ->
			dragData = @dragData
			grid = target.headerCt.grid
			sourceHeader = dragData.header
			targetHeader = Ext.getCmp target.getTargetFromEvent(e)?.id
			return false unless targetHeader
			# only name column could be draggable and droppable
			if 'pivottable' is grid.xtype and 'pivotaxiscolumn' is sourceHeader.xtype and 'pivotaxiscolumn' isnt targetHeader.xtype
				return false
			sourceGroupHeader = sourceHeader.up?()
			targetGroupHeader = targetHeader.up?()

			if grid.isEditing
				return false
			#1 current dragged header is a sub header
			if sourceGroupHeader?.isGroupHeader
				# only allow current header reorder in the same group
				if targetGroupHeader is sourceGroupHeader
					return true
			#2 current dragged header is not a sub header
			else
				# only allow current header drop in the non sub header
				if not (targetGroupHeader and targetGroupHeader.isGroupHeader)
					return true

			return false
		Ext.override Ext.grid.plugin.HeaderReorderer,
			onHeaderCtRender: ->
				me = this
				me.dragZone = new Ext.grid.header.DragZone me.headerCt
				me.dropZone = new Ext.grid.header.DropZone me.headerCt
				if me.disabled
					me.dragZone.disable()
				me.dragZone.beforeDragOver = overrideBeforeDragOver