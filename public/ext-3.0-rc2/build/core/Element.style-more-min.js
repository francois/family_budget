/*
 * Ext JS Library 3.0 RC2
 * Copyright(c) 2006-2009, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */


Ext.Element.boxMarkup='<div class="{0}-tl"><div class="{0}-tr"><div class="{0}-tc"></div></div></div><div class="{0}-ml"><div class="{0}-mr"><div class="{0}-mc"></div></div></div><div class="{0}-bl"><div class="{0}-br"><div class="{0}-bc"></div></div></div>';Ext.Element.addMethods(function(){var INTERNAL="_internal";return{applyStyles:function(style){Ext.DomHelper.applyStyles(this.dom,style);return this;},getStyles:function(){var ret={};Ext.each(arguments,function(v){ret[v]=this.getStyle(v);},this);return ret;},getStyleSize:function(){var me=this,w,h,d=this.dom,s=d.style;if(s.width&&s.width!='auto'){w=parseInt(s.width,10);if(me.isBorderBox()){w-=me.getFrameWidth('lr');}}
if(s.height&&s.height!='auto'){h=parseInt(s.height,10);if(me.isBorderBox()){h-=me.getFrameWidth('tb');}}
return{width:w||me.getWidth(true),height:h||me.getHeight(true)};},setOverflow:function(v){var me=this;if(v=='auto'&&Ext.isMac&&Ext.isGecko2){me.dom.style.overflow='hidden';(function(){me.dom.style.overflow='auto';}).defer(1,me);}else{me.dom.style.overflow=v;}},boxWrap:function(cls){cls=cls||'x-box';var el=Ext.get(this.insertHtml("beforeBegin","<div class='"+cls+"'>"+String.format(Ext.Element.boxMarkup,cls)+"</div>"));Ext.DomQuery.selectNode('.'+cls+'-mc',el.dom).appendChild(this.dom);return el;},setSize:function(width,height,animate){var me=this;if(typeof width=="object"){height=width.height;width=width.width;}
width=me.adjustWidth(width);height=me.adjustHeight(height);if(!animate||!me.anim){me.dom.style.width=me.addUnits(width);me.dom.style.height=me.addUnits(height);}else{me.anim({width:{to:width},height:{to:height}},me.preanim(arguments,2));}
return me;},getComputedHeight:function(){var me=this,h=Math.max(me.dom.offsetHeight,me.dom.clientHeight);if(!h){h=parseInt(me.getStyle('height'),10)||0;if(!me.isBorderBox()){h+=me.getFrameWidth('tb');}}
return h;},getComputedWidth:function(){var w=Math.max(this.dom.offsetWidth,this.dom.clientWidth);if(!w){w=parseInt(this.getStyle('width'),10)||0;if(!this.isBorderBox()){w+=this.getFrameWidth('lr');}}
return w;},getFrameWidth:function(sides,onlyContentBox){return onlyContentBox&&this.isBorderBox()?0:(this.getPadding(sides)+this.getBorderWidth(sides));},addClassOnOver:function(className){this.hover(function(){Ext.fly(this,INTERNAL).addClass(className);},function(){Ext.fly(this,INTERNAL).removeClass(className);});return this;},addClassOnFocus:function(className){this.on("focus",function(){Ext.fly(this,INTERNAL).addClass(className);},this.dom);this.on("blur",function(){Ext.fly(this,INTERNAL).removeClass(className);},this.dom);return this;},addClassOnClick:function(className){var dom=this.dom;this.on("mousedown",function(){Ext.fly(dom,INTERNAL).addClass(className);var d=Ext.getDoc(),fn=function(){Ext.fly(dom,INTERNAL).removeClass(className);d.removeListener("mouseup",fn);};d.on("mouseup",fn);});return this;},getViewSize:function(){var doc=document,d=this.dom,extdom=Ext.lib.Dom,isDoc=(d==doc||d==doc.body);return{width:(isDoc?extdom.getViewWidth():d.clientWidth),height:(isDoc?extdom.getViewHeight():d.clientHeight)};},getSize:function(contentSize){return{width:this.getWidth(contentSize),height:this.getHeight(contentSize)};},repaint:function(){var dom=this.dom;this.addClass("x-repaint");setTimeout(function(){Ext.get(dom).removeClass("x-repaint");},1);return this;},unselectable:function(){this.dom.unselectable="on";return this.swallowEvent("selectstart",true).applyStyles("-moz-user-select:none;-khtml-user-select:none;").addClass("x-unselectable");},getMargins:function(side){var me=this,key,hash={t:"top",l:"left",r:"right",b:"bottom"},o={};if(!side){for(key in me.margins)
o[hash[key]]=parseInt(me.getStyle(me.margins[key]),10)||0;return o;}else{return me.addStyles.call(me,side,me.margins);}}}}());