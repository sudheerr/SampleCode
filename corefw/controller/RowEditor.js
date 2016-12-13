// Generated by CoffeeScript 1.8.0
Ext.define('Corefw.controller.RowEditor', {
  extend: 'Ext.app.Controller',
  init: function() {
    this.control({
      'roweditor checkbox[columnONCHANGEevent]': {
        change: this.onEditorCheckboxChange
      },
      'roweditor checkbox[columnONCHECKCHANGEevent]': {
        change: this.onEditorCheckboxCheckChange
      },
      'roweditor textfield[columnONCHANGEevent]': {
        change: this.onEditorTextfieldChange()
      },
      'roweditor textfield[columnONBLURevent]': {
        blur: this.onEditorTextfieldBlur
      },
      'roweditor combobox[columnONSELECTevent]': {
        select: this.onEditorComboBoxSelect
      },
      'roweditor combobox[columnONCHANGEevent]': {
        change: this.onEditorComboBoxChange
      },
      'roweditor coremonthpicker[columnONSELECTevent]': {
        select: this.onEditorMonthPickerChange
      },
      'roweditor coremonthpicker[columnONCHANGEevent]': {
        change: this.onEditorMonthPickerChange
      },
      'roweditor field': {
        focus: function(comp) {
          var currentColunmn, grid, restoreInfo;
          grid = comp.up('grid');
          if (grid) {
            currentColunmn = grid.columns.filter(function(c) {
              return c.dataIndex === comp.name;
            })[0];
            if (currentColunmn && (restoreInfo = Corefw.util.InternalVar.getByNameProperty('roweditor', 'restoreinfo'))) {
              restoreInfo.columnIndex = grid.columnManager.getHeaderIndex(currentColunmn);
            }
          }
        },
        change: function(comp, newValue) {
          var editor;
          editor = comp.up('roweditor');
          return editor.updateButton(editor.isValid());
        }
      },
      'grid': {
        beforedestroy: this.onEditorHostBeforeDestory
      },
      'treepanel': {
        beforedestroy: this.onEditorHostBeforeDestory
      }
    });
  },
  onEditorHostBeforeDestory: function(host) {
    var rowEditor;
    console.log('grid/tree destory');
    if (host.isEditing) {
      rowEditor = host.rowEditor;
      if (!rowEditor) {
        return;
      }
      rowEditor.hideMask();
    }
  },
  onEditorMonthPickerChange: function(comp, newValue, oldValue) {
    this.fireEditorEvent(comp, 'ONCHANGE', true);
  },
  onEditorCheckboxChange: function(comp) {
    this.fireEditorEvent(comp, 'ONCHANGE', true);
  },
  onEditorCheckboxCheckChange: function(comp) {
    this.fireEditorEvent(comp, 'ONCHECKCHANGE', true);
  },
  onEditorTextfieldChange: function() {
    var task;
    task = new Ext.util.DelayedTask(this.fireEditorEvent, this);
    return function(comp, newValue, oldValue) {
      if (comp.xtype === 'comboboxfield' || comp.xtype === 'coremonthpicker' || comp.xtype === 'coremonthpickerfield') {
        return;
      }
      return task.delay(500, null, null, [comp, 'ONCHANGE', true]);
    };
  },
  onEditorTextfieldBlur: function(comp, event) {
    this.fireEditorEvent(comp, 'ONBLUR', true, event);
  },
  onEditorComboBoxSelect: function(comp) {
    var compXtype, resumeChangeEvent;
    compXtype = comp.xtype;
    if (compXtype === 'roweditorgridpicker') {
      comp.suspendEvent('change');
    }
    this.fireEditorEvent(comp, 'ONSELECT', true, event);
    if (compXtype === 'roweditorgridpicker') {
      resumeChangeEvent = Ext.Function.createDelayed(function() {
        comp.resumeEvent('change');
      }, 1000);
      resumeChangeEvent();
    }
  },
  onEditorComboBoxChange: function(comp) {
    this.fireEditorEvent(comp, 'ONCHANGE', true, event);
  },
  fireEditorEvent: function(comp, evtType, forcedUpdateRec, event) {
    var callbackMethod, editor, errMsg, eventURL, form, iv, lookUpString, method, parent, parentField, postData, record, rq, source, uipath, url, _ref, _ref1;
    if ((!comp.el) || comp.isDisabled()) {
      return;
    }
    console.log('fire the event on roweditor');
    iv = Corefw.util.InternalVar;
    rq = Corefw.util.Request;
    parent = comp.up('grid') || comp.up('treepanel');
    if (iv.getByNameProperty('roweditor', 'suspendChangeEvents')) {
      return;
    }
    source = comp.column;
    eventURL = (_ref = source.cache._myProperties.eventURLs) != null ? _ref[evtType] : void 0;
    if (!eventURL) {
      return;
    }
    iv.setByNameProperty('roweditor', 'suspendChangeEvents', true);
    editor = comp.up('roweditor');
    if (evtType === 'ONBLUR') {
      editor.updateButton(true);
    } else {
      editor.updateButton(false);
    }
    record = (_ref1 = editor.context) != null ? _ref1.record : void 0;
    form = editor.getForm();
    if (forcedUpdateRec && record) {
      form.updateRecord();
    }
    parentField = parent.up('fieldcontainer');
    uipath = parentField.uipath;
    if (evtType === 'ONLOOKUP') {
      postData = null;
      if (!comp.isNotFirstLookUp) {
        comp.isNotFirstLookUp = true;
        lookUpString = '';
      } else {
        lookUpString = comp.getRawValue();
      }
      url = rq.objsToUrl3(eventURL, null, lookUpString);
    } else {
      postData = parentField.generatePostData();
      url = rq.objsToUrl3(eventURL);
      this.applyChangedValue(postData, form, parent.editingPlugin.recordIndex);
    }
    errMsg = 'Did not receive a valid response';
    method = 'POST';
    callbackMethod = this.processEditorEvent(editor, comp);
    rq.sendRequest5(url, callbackMethod, uipath, postData, errMsg, method);
    iv.setByNameProperty('roweditor', 'suspendChangeEvents', false);
  },
  applyChangedValue: function(postData, form, rowIndex) {
    var fieldValues, isBoolean, isDate, isEmpty, isNumber, isString, key, postItem, postValue, postValues, value;
    if (!Ext.isNumber(rowIndex)) {
      return;
    }
    postItem = postData.items[rowIndex];
    postItem.changed = true;
    postItem.editing = true;
    postValues = postData.items[rowIndex].value;
    fieldValues = form.getFieldValues();
    isEmpty = Ext.isEmpty;
    isBoolean = Ext.isBoolean;
    isString = Ext.isString;
    isDate = Ext.isDate;
    isNumber = Ext.isNumber;
    for (key in fieldValues) {
      value = fieldValues[key];
      postValue = null;
      postValue = postValues[key];
      if (isEmpty(value)) {
        continue;
      }
      if (isBoolean(postValue) && (value === 'true' || value === 'false')) {
        value = value === 'true' ? true : false;
      } else if (isString(postValue) && isDate(value)) {
        value = Ext.Date.format(value, 'Y-m-d H:i:s');
      } else if (isNumber(postValue) && isDate(value)) {
        value = value.getTime();
      } else if (value && value.hasOwnProperty('value')) {
        value = value.value;
      }
      if (postValue !== value) {
        postValues[key] = value;
      }
    }
  },
  extractGridResponse: function(uipath, responseObj) {
    var gridResp;
    if (responseObj.uipath === uipath) {
      gridResp = responseObj;
    } else if (Ext.isArray(responseObj)) {
      gridResp = responseObj.filter(function(r) {
        return uipath === r.uipath;
      })[0];
    } else {
      gridResp = this.traverseResponseTree(uipath, responseObj);
    }
    if (!gridResp) {
      gridResp = {
        isSkip: true
      };
    }
    gridResp.isIgnored = true;
    return gridResp;
  },
  traverseResponseTree: function(uipath, responseObj) {
    var allContents, index, response, subResponse, _i, _len;
    if (responseObj.uipath === uipath) {
      return responseObj;
    }
    allContents = responseObj.allContents;
    response = {
      isSkip: true
    };
    for (index = _i = 0, _len = allContents.length; _i < _len; index = ++_i) {
      subResponse = allContents[index];
      response = this.traverseResponseTree(uipath, subResponse);
      if (response) {
        break;
      }
    }
    return response;
  },
  processEditorEvent: function(roweditor) {
    var cm, controller, editingPlugin, grid, helper, iv, parent, _ref;
    cm = Corefw.util.Common;
    helper = Corefw.util.RowEditorHelper;
    controller = this;
    iv = Corefw.util.InternalVar;
    grid = (_ref = roweditor.context) != null ? _ref.grid : void 0;
    editingPlugin = roweditor.editingPlugin;
    editingPlugin.isProcessingEvent = true;
    if (!grid) {
      return function() {};
    }
    parent = grid.ownerCt;
    return function(responseObj, ev, triggerUipath) {
      var cacheObject, context, gridCache, gridResp, isValid, name, newRowItem, newRowItems, props, rowIndex;
      editingPlugin.isProcessingEvent = false;
      context = roweditor.context;
      if (!(parent || context || !roweditor.isVisible())) {
        return;
      }
      roweditor.updateButton(true);
      if (!roweditor.el) {
        if (typeof editingPlugin.hideMask === "function") {
          editingPlugin.hideMask();
        }
        return;
      }
      gridResp = controller.extractGridResponse(parent.uipath, responseObj);
      Ext.defer(function() {
        return Corefw.util.Request.processResponseObject(responseObj, 1);
      });
      if (gridResp.isSkip) {
        return;
      }
      if (gridResp.cancelEditing) {
        grid.isEditing = false;
        cacheObject = Corefw.util.Cache.parseJsonToCache(gridResp);
        name = parent.cache._myProperties.name;
        gridCache = cacheObject[name];
        if (typeof grid.updateFromCache === "function") {
          grid.updateFromCache(gridCache);
        }
        if (editingPlugin != null) {
          if (typeof editingPlugin.cancelEdit === "function") {
            editingPlugin.cancelEdit();
          }
        }
        return;
      }
      rowIndex = editingPlugin.recordIndex;
      props = parent.cache._myProperties;
      props.allContents = gridResp.allContents;
      if (gridResp.widgetType === 'TREE_GRID') {
        newRowItems = cm.converTreeGridDataToDataList(gridResp.allTopLevelNodes);
        props.allTopLevelNodes = gridResp.allTopLevelNodes;
      } else {
        props.items = gridResp.items;
        newRowItems = gridResp.items;
      }
      newRowItem = newRowItems[rowIndex];
      helper = Corefw.util.RowEditorHelper;
      editingPlugin.suspendChangeEvents = true;
      helper.updateFieldValueFromResponse(roweditor, newRowItem);
      helper.bindHistoryInfoToCombobox(roweditor, props.allContents, newRowItem);
      helper.retrieveEditingRowData(context, roweditor);
      helper.disableOrEnableCells(roweditor);
      helper.addMoreActionsToRowEditor(roweditor);
      editingPlugin.suspendChangeEvents = false;
      isValid = roweditor.isValid();
      isValid && helper.updateRecord(context.record, newRowItem.value);
      roweditor.updateButton(isValid);
      iv.setByNameProperty('roweditor', 'suspendChangeEvents', false);
      if (isValid && editingPlugin.shouldResumeUpdating) {
        editingPlugin.completeEdit();
      }
    };
  }
});