Ext.define 'Corefw.view.form.field.Number',
	extend: 'Ext.form.field.Number'
	mixins: ['Corefw.mixin.CoreField']
	xtype: 'corenumberfield'
	decimalSeparator: '.'
	baseChars: '0123456789'
	allowedCharsRe: /[-\d.]/g
	allowedPseudoClassRe: /^abs:/
	negativeSymbolRe: /^[-]/
	nanText: '{0} is not a valid number'
	autoStripChars: false
	decimalPrecision: 5
	allowDecimals: true
	enableKeyEvents: true

	initComponent: ->
		@callParent arguments
		@initializeField()
		return

	initValueFloatingLabel: ->
		me = this
		id = me.id + 'floating-label'
		valueLabel = Ext.getCmp id
		if not valueLabel
			valueLabel = Ext.create 'Ext.form.Label',
				id: id
				hidden: true
				shadow: false
				floating: true
				renderTo: Ext.getBody()
				margin: '0 0 0 0'
				style:
					'padding-top': '0.1%'
					'padding-left': '4px'
					'background-color': '#dae7f6'
					border: '1px solid rgb(154, 193, 239)'
			valueLabel.el.setZIndex 1900000
		me.valueLabel = valueLabel
		if me.value
			me.valueLabel.setText me.formatValue me.value
		return
	adjustValueFloatingLabel: ->
		me = this
		if me.valueLabel
			valueLabel = me.valueLabel
			valueLabel.el.setXY [me.inputEl.getX(), me.inputEl.getY() + me.inputEl.getHeight()]
			valueLabel.el.setWidth me.inputEl.getWidth() + me.spinUpEl.getWidth()
			valueLabel.el.setHeight me.inputEl.getHeight()
		return

	initializeField: (value) ->
		me = this
		su = Corefw.util.Startup
		if me.minValue is undefined
			me.minValue = Ext.Number.from value, Number.NEGATIVE_INFINITY
		if me.maxValue is undefined
			me.maxValue = Ext.Number.from value, Number.MAX_VALUE

		allowed = @baseChars + @decimalSeparator + '-'
		allowed = Ext.String.escapeRegex allowed
		me.maskRe = new RegExp "[#{allowed}]"
		if not me.cache
			me.cache = me.column.cache
		props = me.cache._myProperties
		me.parsePseudoClass()
		if su.getThemeVersion() is 2 and props.readOnly isnt true
			me.fieldStyle =
				borderRightWidth: '0px'
		return

	listeners:
		boxready: (comp, width, height) ->
			comp.format and comp.initValueFloatingLabel()

		focus: (comp, ev) ->
			value = comp.getValue()
			comp.adjustValueFloatingLabel()
			comp.setRawValue comp.getValue()
			comp.editing = true
			if comp.format and valueLabel = comp.valueLabel
				comp.updateValueLabel value
				valueLabel.el.dom.style.visibility = ''
			return

		blur: (comp) ->
			comp.editing = false
			if comp.format
				comp.valueLabel?.el.hide()
				comp.setRawValue comp.formatValue comp.getValue()
			return

		change: (comp, newValue, oldValue) ->
			if comp.hasOwnProperty('minValue')
				if newValue < comp.minValue and comp.minValue is 0
					newValue = Math.abs newValue
					comp.setValue newValue
			comp.format and comp.valueLabel?.setText comp.formatValue newValue

		destroy: ->
			@valueLabel?.destroy()

		specialkey: (comp, e) ->
			# e.HOME, e.END, e.ENTER, e.PAGE_UP, e.PAGE_DOWN,
			# e.TAB, e.ESC, arrow keys: e.LEFT, e.RIGHT, e.UP, e.DOWN
			key = e.getKey()
			if comp.format and (valueLabel = comp.valueLabel) and (key is e.TAB or key is e.ENTER)
				valueLabel.el.hide()

	setSpinValue: (value) ->
		@isSpinValue = true
		@callParent arguments
		delete @isSpinValue

	setValue: (value) ->
		@callParent arguments
		@updateValueLabel value
		return

	updateValueLabel: (value) ->
		if @format and valueLabel = @valueLabel
			valueLabel.setText @formatValue value
		return

	formatValue: (value) ->
		if @format
			if @isAbsOnly
				value = Math.abs value
			return Ext.util.Format.number value, @format
		return value

	valueToRaw: ->
		rawValue = @callParent arguments
		return if (not @isSpinValue and not @editing) then (@formatValue rawValue) else rawValue

	fixPrecision: (value) ->
		me = this
		nan = isNaN(value)
		precision = me.decimalPrecision
		if nan or not value
			return (if nan then '' else value)
		else precision = 0  if not me.allowDecimals or precision <= 0

		expandedValue = parseFloat(value) * Math.pow(10, precision)
		roundValue = Math.round(expandedValue)
		return parseFloat Ext.Number.toFixed(roundValue / Math.pow(10, precision), precision)

	parsePseudoClass: ->
		return unless @format
		me = this
		format = me.format
		allowedPseudoClassRe = me.allowedPseudoClassRe
		matchedClasses = format.match allowedPseudoClassRe
		return unless matchedClasses
		for pClass in matchedClasses
			if pClass is 'abs:'
				me.isAbsOnly = true
		me.format = format.replace allowedPseudoClassRe, ''
		return

	parseValue: (value) ->
		if value is -0 or value is '-0'
			return -0
		matchedValues = String(value).match(@allowedCharsRe)
		return null if not matchedValues
		value = parseFloat matchedValues.join ''
		if isNaN(value) then null else @fixPrecision value

	parseValueAsStr: (value) ->
		value = @parseValue value
		if not value
			return ''
		else
			return String value

	getErrors: (value) ->
		me = this
		value = (@parseValue value) or 0
		value = String(value).replace me.decimalSeparator, '.'
		arguments[0] = value
		errors = me.callParent arguments
		format = Ext.String.format
		value = (if Ext.isDefined(value) then value else @processRawValue(@getRawValue()))
		# if it's blank and textfield didn't flag it then it's valid
		return errors  if not value or value.length < 1
		num = me.parseValue(value)
		if me.minValue is 0 and num < 0
			errors.push @negativeText
		else errors.push format(me.minText, me.minValue)  if num < me.minValue
		errors.push format(me.maxText, me.maxValue)  if num > me.maxValue
		errors

	getRawValue: ->
		rawValue = @callParent arguments
		if not @rendered or (Ext.isEmpty rawValue) or (@format and @editing) or Ext.isNumber Ext.Number.from rawValue # make sure the value is still correct when field doesn't have the format
			return rawValue
		else
			return @value