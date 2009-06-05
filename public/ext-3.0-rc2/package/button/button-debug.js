/*
 * Ext JS Library 3.0 RC2
 * Copyright(c) 2006-2009, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */



Ext.Button = Ext.extend(Ext.BoxComponent, {
    
    hidden : false,
    
    disabled : false,
    
    pressed : false,
    

    

    

    
    enableToggle: false,
    
    
    
    menuAlign : "tl-bl?",

    
    
    type : 'button',

    // private
    menuClassTarget: 'tr:nth(2)',

    
    clickEvent : 'click',

    
    handleMouseEvents : true,

    
    tooltipType : 'qtip',

    
    buttonSelector : "button:first-child",

    
    scale: 'small',

    
    iconAlign : 'left',

    
    arrowAlign : 'right',

    
    
    

    initComponent : function(){
        Ext.Button.superclass.initComponent.call(this);

        this.addEvents(
            
            "click",
            
            "toggle",
            
            'mouseover',
            
            'mouseout',
            
            'menushow',
            
            'menuhide',
            
            'menutriggerover',
            
            'menutriggerout'
        );
        if(this.menu){
            this.menu = Ext.menu.MenuMgr.get(this.menu);
        }
        if(typeof this.toggleGroup === 'string'){
            this.enableToggle = true;
        }
    },


    getTemplateArgs : function(){
        var cls = (this.cls || '');
        cls += (this.iconCls || this.icon) ? (this.text ? ' x-btn-text-icon' : ' x-btn-icon') : ' x-btn-noicon';
        if(this.pressed){
            cls += ' x-btn-pressed';
        }
        return [this.text || '&#160;', this.type, this.iconCls || '', cls, 'x-btn-' + this.scale + ' x-btn-icon-' + this.scale + '-' + this.iconAlign, this.getMenuClass()];
    },

    // protected
    getMenuClass : function(){
        return this.menu ? (this.arrowAlign != 'bottom' ? 'x-btn-arrow' : 'x-btn-arrow-bottom') : '';
    },

    // private
    onRender : function(ct, position){
        if(!this.template){
            if(!Ext.Button.buttonTemplate){
                // hideous table template
                Ext.Button.buttonTemplate = new Ext.Template(
                    '<table cellspacing="0" class="x-btn {3}"><tbody class="{4}">',
                    '<tr><td class="x-btn-tl"><i>&#160;</i></td><td class="x-btn-tc"></td><td class="x-btn-tr"><i>&#160;</i></td></tr>',
                    '<tr><td class="x-btn-ml"><i>&#160;</i></td><td class="x-btn-mc"><em class="{5}" unselectable="on"><button class="x-btn-text {2}" type="{1}">{0}</button></em></td><td class="x-btn-mr"><i>&#160;</i></td></tr>',
                    '<tr><td class="x-btn-bl"><i>&#160;</i></td><td class="x-btn-bc"></td><td class="x-btn-br"><i>&#160;</i></td></tr>',
                    "</tbody></table>");
                Ext.Button.buttonTemplate.compile();
            }
            this.template = Ext.Button.buttonTemplate;
        }

        var btn, targs = this.getTemplateArgs();

        if(position){
            btn = this.template.insertBefore(position, targs, true);
        }else{
            btn = this.template.append(ct, targs, true);
        }
        
        var btnEl = this.btnEl = btn.child(this.buttonSelector);
        this.mon(btnEl, 'focus', this.onFocus, this);
        this.mon(btnEl, 'blur', this.onBlur, this);

        this.initButtonEl(btn, btnEl);

        Ext.ButtonToggleMgr.register(this);
    },

    // private
    initButtonEl : function(btn, btnEl){
        this.el = btn;

        if(this.id){
            this.el.dom.id = this.el.id = this.id;
        }
        if(this.icon){
            btnEl.setStyle('background-image', 'url(' +this.icon +')');
        }
        if(this.tabIndex !== undefined){
            btnEl.dom.tabIndex = this.tabIndex;
        }
        if(this.tooltip){
            this.setTooltip(this.tooltip);
        }

        if(this.handleMouseEvents){
            this.mon(btn, 'mouseover', this.onMouseOver, this);
            this.mon(btn, 'mousedown', this.onMouseDown, this);
            
            // new functionality for monitoring on the document level
            //this.mon(btn, "mouseout", this.onMouseOut, this);
        }

        if(this.menu){
            this.mon(this.menu, 'show', this.onMenuShow, this);
            this.mon(this.menu, 'hide', this.onMenuHide, this);
        }

        if(this.repeat){
            var repeater = new Ext.util.ClickRepeater(btn,
                typeof this.repeat == "object" ? this.repeat : {}
            );
            this.mon(repeater, 'click', this.onClick, this);
        }
        
        this.mon(btn, this.clickEvent, this.onClick, this);
    },

    // private
    afterRender : function(){
        Ext.Button.superclass.afterRender.call(this);
        if(Ext.isIE6){
            this.doAutoWidth.defer(1, this);
        }else{
            this.doAutoWidth();
        }
    },

    
    setIconClass : function(cls){
        if(this.el){
            this.btnEl.replaceClass(this.iconCls, cls);
        }
        this.iconCls = cls;
        return this;
    },

    
    setTooltip : function(tooltip){
        if(Ext.isObject(tooltip)){
            Ext.QuickTips.register(Ext.apply({
                  target: this.btnEl.id
            }, tooltip));
        } else {
            this.btnEl.dom[this.tooltipType] = tooltip;
        }
        return this;
    },
    
    // private
    beforeDestroy: function(){
        if(this.rendered){
            if(this.btnEl){
                if(typeof this.tooltip == 'object'){
                    Ext.QuickTips.unregister(this.btnEl);
                }
            }
        }
        Ext.destroy(this.menu);
    },

    // private
    onDestroy : function(){
        if(this.rendered){
            Ext.ButtonToggleMgr.unregister(this);
        }
    },

    // private
    doAutoWidth : function(){
        if(this.el && this.text && typeof this.width == 'undefined'){
            this.el.setWidth("auto");
            if(Ext.isIE7 && Ext.isStrict){
                var ib = this.btnEl;
                if(ib && ib.getWidth() > 20){
                    ib.clip();
                    ib.setWidth(Ext.util.TextMetrics.measure(ib, this.text).width+ib.getFrameWidth('lr'));
                }
            }
            if(this.minWidth){
                if(this.el.getWidth() < this.minWidth){
                    this.el.setWidth(this.minWidth);
                }
            }
        }
    },

    
    setHandler : function(handler, scope){
        this.handler = handler;
        this.scope = scope;
        return this;
    },

    
    setText : function(text){
        this.text = text;
        if(this.el){
            this.el.child("td.x-btn-mc " + this.buttonSelector).update(text);
        }
        this.doAutoWidth();
        return this;
    },

    
    getText : function(){
        return this.text;
    },

    
    toggle : function(state, suppressEvent){
        state = state === undefined ? !this.pressed : !!state;
        if(state != this.pressed){
            this.el[state ? 'addClass' : 'removeClass']("x-btn-pressed");
            this.pressed = state;
            if(!suppressEvent){
                this.fireEvent("toggle", this, state);
                if(this.toggleHandler){
                    this.toggleHandler.call(this.scope || this, this, state);
                }
            }
        }
        return this;
    },

    
    focus : function(){
        this.btnEl.focus();
    },

    // private
    onDisable : function(){
        this.onDisableChange(true);
    },

    // private
    onEnable : function(){
        this.onDisableChange(false);
    },
    
    onDisableChange : function(disabled){
        if(this.el){
            if(!Ext.isIE6 || !this.text){
                this.el[disabled ? 'addClass' : 'removeClass'](this.disabledClass);
            }
            this.el.dom.disabled = disabled;
        }
        this.disabled = disabled;
    },

    
    showMenu : function(){
        if(this.menu){
            this.menu.show(this.el, this.menuAlign);
        }
        return this;
    },

    
    hideMenu : function(){
        if(this.menu){
            this.menu.hide();
        }
        return this;
    },

    
    hasVisibleMenu : function(){
        return this.menu && this.menu.isVisible();
    },

    // private
    onClick : function(e){
        if(e){
            e.preventDefault();
        }
        if(e.button != 0){
            return;
        }
        if(!this.disabled){
            if(this.enableToggle && (this.allowDepress !== false || !this.pressed)){
                this.toggle();
            }
            if(this.menu && !this.menu.isVisible() && !this.ignoreNextClick){
                this.showMenu();
            }
            this.fireEvent("click", this, e);
            if(this.handler){
                //this.el.removeClass("x-btn-over");
                this.handler.call(this.scope || this, this, e);
            }
        }
    },

    // private
    isMenuTriggerOver : function(e, internal){
        return this.menu && !internal;
    },

    // private
    isMenuTriggerOut : function(e, internal){
        return this.menu && !internal;
    },

    // private
    onMouseOver : function(e){
        if(!this.disabled){
            var internal = e.within(this.el,  true);
            if(!internal){
                this.el.addClass("x-btn-over");
                if(!this.monitoringMouseOver){
                    Ext.getDoc().on('mouseover', this.monitorMouseOver, this);
                    this.monitoringMouseOver = true;
                }
                this.fireEvent('mouseover', this, e);
            }
            if(this.isMenuTriggerOver(e, internal)){
                this.fireEvent('menutriggerover', this, this.menu, e);
            }
        }
    },

    // private
    monitorMouseOver : function(e){
        if(e.target != this.el.dom && !e.within(this.el)){
            if(this.monitoringMouseOver){
                Ext.getDoc().un('mouseover', this.monitorMouseOver, this);
                this.monitoringMouseOver = false;
            }
            this.onMouseOut(e);
        }
    },

    // private
    onMouseOut : function(e){
        var internal = e.within(this.el) && e.target != this.el.dom;
        this.el.removeClass("x-btn-over");
        this.fireEvent('mouseout', this, e);
        if(this.isMenuTriggerOut(e, internal)){
            this.fireEvent('menutriggerout', this, this.menu, e);
        }
    },
    // private
    onFocus : function(e){
        if(!this.disabled){
            this.el.addClass("x-btn-focus");
        }
    },
    // private
    onBlur : function(e){
        this.el.removeClass("x-btn-focus");
    },

    // private
    getClickEl : function(e, isUp){
       return this.el;
    },

    // private
    onMouseDown : function(e){
        if(!this.disabled && e.button == 0){
            this.getClickEl(e).addClass("x-btn-click");
            Ext.getDoc().on('mouseup', this.onMouseUp, this);
        }
    },
    // private
    onMouseUp : function(e){
        if(e.button == 0){
            this.getClickEl(e, true).removeClass("x-btn-click");
            Ext.getDoc().un('mouseup', this.onMouseUp, this);
        }
    },
    // private
    onMenuShow : function(e){
        this.ignoreNextClick = 0;
        this.el.addClass("x-btn-menu-active");
        this.fireEvent('menushow', this, this.menu);
    },
    // private
    onMenuHide : function(e){
        this.el.removeClass("x-btn-menu-active");
        this.ignoreNextClick = this.restoreClick.defer(250, this);
        this.fireEvent('menuhide', this, this.menu);
    },

    // private
    restoreClick : function(){
        this.ignoreNextClick = 0;
    }



    
});
Ext.reg('button', Ext.Button);

// Private utility class used by Button
Ext.ButtonToggleMgr = function(){
   var groups = {};

   function toggleGroup(btn, state){
       if(state){
           var g = groups[btn.toggleGroup];
           for(var i = 0, l = g.length; i < l; i++){
               if(g[i] != btn){
                   g[i].toggle(false);
               }
           }
       }
   }

   return {
       register : function(btn){
           if(!btn.toggleGroup){
               return;
           }
           var g = groups[btn.toggleGroup];
           if(!g){
               g = groups[btn.toggleGroup] = [];
           }
           g.push(btn);
           btn.on("toggle", toggleGroup);
       },

       unregister : function(btn){
           if(!btn.toggleGroup){
               return;
           }
           var g = groups[btn.toggleGroup];
           if(g){
               g.remove(btn);
               btn.un("toggle", toggleGroup);
           }
       },

       
       getPressed : function(group){
           var g = groups[group];
           if(g){
               for(var i = 0, len = g.length; i < len; i++){
                   if(g[i].pressed === true){
                       return g[i];
                   }
               }
           }
           return null;
       }
   };
}();

Ext.SplitButton = Ext.extend(Ext.Button, {
	// private
    arrowSelector : 'em',
    split: true,

    // private
    initComponent : function(){
        Ext.SplitButton.superclass.initComponent.call(this);
        
        this.addEvents("arrowclick");
    },

    // private
    onRender : function(){
        Ext.SplitButton.superclass.onRender.apply(this, arguments);
        if(this.arrowTooltip){
            btn.child(this.arrowSelector).dom[this.tooltipType] = this.arrowTooltip;
        }
    },

    
    setArrowHandler : function(handler, scope){
        this.arrowHandler = handler;
        this.scope = scope;
    },

    getMenuClass : function(){
        return this.menu && this.arrowAlign != 'bottom' ? 'x-btn-split' : 'x-btn-split-bottom';
    },

    isClickOnArrow : function(e){
        return this.arrowAlign != 'bottom' ?
               e.getPageX() > this.el.child(this.buttonSelector).getRegion().right :
               e.getPageY() > this.el.child(this.buttonSelector).getRegion().bottom;
    },

    // private
    onClick : function(e, t){
        e.preventDefault();
        if(!this.disabled){
            if(this.isClickOnArrow(e)){
                if(this.menu && !this.menu.isVisible() && !this.ignoreNextClick){
                    this.showMenu();
                }
                this.fireEvent("arrowclick", this, e);
                if(this.arrowHandler){
                    this.arrowHandler.call(this.scope || this, this, e);
                }
            }else{
                if(this.enableToggle){
                    this.toggle();
                }
                this.fireEvent("click", this, e);
                if(this.handler){
                    this.handler.call(this.scope || this, this, e);
                }
            }
        }
    },

    // private
    isMenuTriggerOver : function(e){
        return this.menu && e.target.tagName == 'em';
    },

    // private
    isMenuTriggerOut : function(e, internal){
        return this.menu && e.target.tagName != 'em';
    }
});

Ext.reg('splitbutton', Ext.SplitButton);
