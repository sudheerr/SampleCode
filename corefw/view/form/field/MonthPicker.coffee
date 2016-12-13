Ext.define 'Corefw.view.form.field.MonthPicker',
	extend: 'Ext.form.field.Date'
	mixins: ['Corefw.mixin.CoreField']
	requires: ['Ext.picker.Month']
	alias: 'widget.monthfield'
	alternateClassName: ['Ext.form.MonthPicker', 'Ext.form.MonthPicker']
	xtype: 'coremonthpicker'
	selectMonth: null
	format: 'Y-m'
	initComponent: ->
		me = this
		props = @cache?._myProperties or {}
		me.day = 1
		me.suspendChangeEvents = true
		props.value and me.value = new Date(props.value)
		@callParent arguments
		return

	createPicker: ->
		me = this
		format = Ext.String.format
		# record the original date, for rolling back purpose.
		me.bakupSelectMonth = me.value
		Ext.create 'Ext.picker.Month',
			height: 195
			pickerField: me
			ownerCt: me.ownerCt
			renderTo: document.body
			floating: true
			hidden: true
			focusOnShow: true
			minDate: me.minValue
			maxDate: me.maxValue
			disabledDatesRE: me.disabledDatesRE
			disabledDatesText: me.disabledDatesText
			disabledDays: me.disabledDays
			disabledDaysText: me.disabledDaysText
			format: 'Y-m'
			startDay: me.startDay
			minText: format me.minText, me.formatDate me.minValue
			maxText: format me.maxText, me.formatDate me.maxValue
			listeners:
				select:
					scope: me
					fn: me.onSelect
				monthdblclick:
					scope: me
					fn: me.onOKClick
				yeardblclick:
					scope: me
					fn: me.onOKClick
				OkClick:
					scope: me
					fn: me.onOKClick
				CancelClick:
					scope: me
					fn: me.onCancelClick
			keyNavConfig:
				esc: ->
					me.collapse()
	createValue: (selectValue) ->
		[month, year] = selectValue or @picker.value
		month++
		if month < 10
			month = '0' + month
		return "#{year}-#{month}"
	onCancelClick: ->
		@collapse()
		return
	onOKClick: ->
		me = this
		me.setValue me.createValue()
		me.collapse()
		return
	onSelect: (comp, selectValue) ->
		value = @createValue selectValue
		@fireEvent 'select', this, new Date value
		return

	afterRender: ->
		@callParent arguments
		delete @suspendChangeEvents
		return
	getValue: ->
		d = @rawToValue(@getRawValue()) or ''
		if not (d instanceof Date)
			return d
		else
			month = d.getMonth() + 1
			return d.getFullYear() + (if month < 10 then '-0' else '-') + month
	setValue: (value) ->
		if Ext.isNumber value
			value = Ext.date.format new Date(value), @format
		else if Ext.isDate value
			value = Ext.Date.format value, @format
		arguments[0] = value or ''
		@callParent arguments