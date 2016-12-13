// Generated by CoffeeScript 1.8.0
Ext.define("Corefw.view.form.field.toggle.ToggleSlide", {
  extend: "Ext.Component",
  requires: ["Ext.fx.Anim"],
  duration: 120,
  onText: "ON",
  offText: "OFF",
  resizeHandle: true,
  resizeContainer: true,
  onLabelCls: "x-toggle-slide-label-on",
  offLabelCls: "x-toggle-slide-label-off",
  handleCls: "x-toggle-slide-thumb",
  disabledCls: "x-toggle-slide-disabled",
  state: false,
  booleanMode: true,
  dragging: false,
  diff: 0,
  diff2: 0,
  diff3: 0,
  frame: false,
  renderTpl: ["<div class=\"holder\">", "<label class=\"{onLabelCls}\">", "<span>{onText}</span>", "</label>", "<label class=\"{offLabelCls}\">", "<span>{offText}</span>", "</label>", "</div>"],
  autoEl: {
    tag: "div",
    cls: "x-toggle-slide-container"
  },
  initComponent: function() {
    var me;
    me = this;
    me.callParent(arguments);
    me.addEvents("beforechange", "change");
  },
  beforeRender: function() {
    var me;
    me = this;
    me.callParent();
    Ext.applyIf(me.renderData, {
      offLabelCls: me.offLabelCls,
      offText: me.offText,
      onLabelCls: me.onLabelCls,
      onText: me.onText,
      handleCls: me.handleCls
    });
  },
  onRender: function() {
    var holder, me;
    me = this;
    if (!me.resizeContainer) {
      me.diff = 0;
    }
    if (!me.resizeHandle) {
      me.diff2 = 3;
      me.diff3 = 5;
    }
    me.callParent(arguments);
    if (me.cls) {
      me.el.addCls(me.cls);
    }
    me.thumb = new Corefw.view.form.field.toggle.Thumb({
      ownerCt: me,
      slider: me,
      disabled: !!me.disabled
    });
    holder = me.el.first();
    me.onLabel = holder.first();
    me.onSpan = me.onLabel.first();
    me.offLabel = me.onLabel.next();
    me.offSpan = me.offLabel.first();
    if (me.rendered) {
      me.thumb.render();
    }
    me.handle = me.thumb.el;
    if (me.resizeHandle) {
      me.thumb.bringToFront();
    } else {
      me.thumb.sendToBack();
    }
    me.resize();
    me.disableTextSelection();
    if (!me.disabled) {
      me.registerToggleListeners();
    } else {
      Corefw.view.form.field.toggle.ToggleSlide.superclass.disable.call(me);
    }
  },
  resize: function() {
    var b, container, expandPx, handle, max, me, min, offlabel, onlabel, rightside, su;
    su = Corefw.util.Startup;
    me = this;
    container = me.el;
    offlabel = me.offLabel;
    onlabel = me.onLabel;
    handle = me.handle;
    if (su.getThemeVersion() !== 2) {
      if (me.resizeHandle) {
        min = (onlabel.getWidth() < offlabel.getWidth() ? onlabel.getWidth() : offlabel.getWidth());
        handle.setWidth(min);
      }
      if (me.resizeContainer) {
        max = (onlabel.getWidth() > offlabel.getWidth() ? onlabel.getWidth() : offlabel.getWidth());
        expandPx = Math.ceil(container.getHeight() / 3);
        container.setWidth(max + handle.getWidth() + expandPx);
      }
      b = handle.getWidth() / 2;
      onlabel.setWidth(container.getWidth() - b + me.diff2);
      offlabel.setWidth(container.getWidth() - b + me.diff2);
      rightside = me.rightside = container.getWidth() - handle.getWidth() - me.diff;
      if (me.state) {
        handle.setLeft(rightside);
      } else {
        handle.setLeft(0);
      }
    } else {
      onlabel.setWidth(container.getWidth() / 2);
      offlabel.setWidth(container.getWidth() / 2);
    }
    me.onDrag();
  },
  disableTextSelection: function() {
    var els;
    els = [this.el, this.onLabel, this.offLabel, this.handle];
    Ext.each(els, function(el) {
      el.on("mousedown", function(evt) {
        evt.preventDefault();
        return false;
      });
      if (Ext.isIE) {
        el.on("startselect", function(evt) {
          evt.stopEvent();
          return false;
        });
      }
    });
  },
  moveHandle: function(on_, callback) {
    var me, runner, to;
    me = this;
    runner = new Ext.util.TaskRunner();
    to = (on_ ? me.rightside : 0);
    if (me.handle) {
      Ext.create("Ext.fx.Anim", {
        target: me.handle,
        dynamic: true,
        easing: "easeOut",
        duration: me.duration,
        to: {
          left: to
        },
        listeners: {
          beforeanimate: {
            fn: function(ani) {
              me.task = runner.newTask({
                run: function() {
                  me.onDrag();
                },
                interval: 10
              });
              me.task.start();
            },
            scope: this
          },
          afteranimate: {
            fn: function(ani) {
              me.onDrag();
              me.task.destroy();
            },
            scope: this
          }
        },
        callback: callback
      });
    }
  },
  onDragStart: function(e) {
    var me;
    me = this;
    me.dragging = true;
    me.dd.constrainTo(me.el, {
      right: me.diff
    });
  },
  onDragEnd: function(e) {
    var cc, hc, me, next;
    me = this;
    hc = (me.handle.getLeft(true) + me.handle.getRight(true)) / 2;
    cc = (me.el.getLeft(true) + me.el.getRight(true)) / 2;
    next = hc > cc;
    if (me.state !== next) {
      me.toggle();
    } else {
      me.moveHandle(next);
    }
    me.dragging = false;
  },
  onDrag: function(e) {
    var me, p, su;
    me = this;
    su = Corefw.util.Startup;
    p = me.handle.getLeft(true) - me.rightside;
    p = (me.handle.getLeft(true) === me.rightside ? 0 : p - me.diff3);
    if (su.getThemeVersion() === 2) {
      if (me.state) {
        me.onLabel.setStyle({
          color: '#2B2B2B',
          backgroundColor: '#CCF2FC',
          borderRight: '1px solid #b5b6b7'
        });
        me.offLabel.setStyle({
          color: '#b6b7b9',
          backgroundColor: '#fff',
          borderLeft: 0
        });
      } else {
        me.onLabel.setStyle({
          color: '#b6b7b9',
          backgroundColor: '#fff',
          borderRight: 0
        });
        me.offLabel.setStyle({
          color: '#2B2B2B',
          backgroundColor: '#CCF2FC',
          borderLeft: '1px solid #b5b6b7'
        });
      }
    } else {
      me.onLabel.setStyle({
        marginLeft: p + "px"
      });
    }
  },
  onMouseUp: function() {
    if (!this.dragging) {
      this.toggle();
    }
  },
  toggle: function() {
    var me, next;
    me = this;
    next = !this.state;
    if (!me.booleanMode) {
      next = (me.state ? me.onText : me.offText);
    }
    if (me.fireEvent("beforechange", me, next) !== false) {
      me.state = !me.state;
      me.moveHandle(me.state, Ext.bind(me.fireEvent, me, ["change", me, me.getValue()]));
    } else {
      me.moveHandle(me.state);
    }
  },
  enable: function() {
    if (this.disabled) {
      Corefw.view.form.field.toggle.ToggleSlide.superclass.enable.call(this);
      this.registerToggleListeners();
    }
    return this;
  },
  disable: function() {
    if (!this.disabled) {
      Corefw.view.form.field.toggle.ToggleSlide.superclass.disable.call(this);
      this.unregisterToggleListeners();
    }
    return this;
  },
  registerToggleListeners: function() {
    var me;
    me = this;
    me.dd = new Ext.dd.DD(me.handle);
    me.dd.startDrag = Ext.bind(me.onDragStart, me);
    me.dd.onDrag = Ext.bind(me.onDrag, me);
    me.dd.endDrag = Ext.bind(me.onDragEnd, me);
    me.el.on("mouseup", me.onMouseUp, me);
  },
  unregisterToggleListeners: function() {
    Ext.destroy(this.dd);
    this.el.un("mouseup", this.onMouseUp, this);
  },
  getValue: function() {
    var me;
    me = this;
    if (me.booleanMode) {
      return me.state;
    } else {
      if (me.state) {
        return me.onText;
      } else {
        return me.offText;
      }
    }
  }
});
