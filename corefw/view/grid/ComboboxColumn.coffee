Ext.define 'Corefw.view.grid.ComboboxColumn',
	extend: 'Ext.grid.column.Column'
	xtype: 'corecombocolumn'
	listConfig:
		resizable:
			listeners:
				beforeresize: ()->
					this.resizeTracker.maxHeight = 10000
					this.target.maxHeight = 10000
					return
				resize: ()->
					this.resizeTracker.maxHeight = 300
					this.target.maxHeight = 300
					return

# pass the in valid values for this combobox here
# test
	validValues: null

# look up display values by value
	validLookup: {}

	initComponent: ->
		@callParent arguments

		validValues = @validValues
		validLookup = @validLookup

		if validValues and validValues.length
			for val in validValues
				if Ext.isObject val and val.value? and val.displayValue?
					validLookup[val.value] = val.displayValue
				else
					@validLookup[val] = val

		return



	defaultRenderer: (value) ->
		me = this
		renderDisplayValue = (val) ->
			if Ext.isObject(val)
				if val.displayValue?
					return val.displayValue
				if    val.value?
					return val.value
			# return the associated display value for this combobox value
			retVal = me.validLookup[val]
			if retVal
				return retVal
			return val

		if Ext.isArray(value)
			arr = []
			Ext.each(value, (item) ->
				arr.push renderDisplayValue(item)
				return
			)
			return arr.join ', '


		return renderDisplayValue value
