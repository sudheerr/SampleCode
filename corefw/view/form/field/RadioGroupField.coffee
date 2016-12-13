Ext.define 'Corefw.view.form.field.RadioGroupField',
	extend: 'Ext.form.RadioGroup'
	mixins: ['Corefw.mixin.CoreField']
	xtype: 'coreradiogroup'
	coretype: 'field'

	listeners:
		boxready: (comp) ->
			radio = comp.el.query('input[type=button]')[0]
			radioWidth = radio.offsetWidth
			span = document.createElement 'span'
			document.body.appendChild span
			comp.el.query('.x-form-radio-group').forEach (ct) ->
				maxText = ''
				labels = ct.querySelectorAll('input+label')
				# to find the text has max length to calculate min width for each radio item/items
				for label in labels
					text = label.innerText
					text.length > maxText.length and maxText = text
				span.innerText = maxText
				ct.style.minWidth = radioWidth + span.offsetWidth + 20 + 'px'
			document.body.removeChild(span)

	generatePostData: ->
		val = @getValue() or {}
		name = @name
		fieldObj =
			name: name
			value: if (val[name] isnt undefined and val[name] isnt null) then val[name] else ''
		return fieldObj