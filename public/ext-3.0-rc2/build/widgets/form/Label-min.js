/*
 * Ext JS Library 3.0 RC2
 * Copyright(c) 2006-2009, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */


Ext.form.Label=Ext.extend(Ext.BoxComponent,{onRender:function(ct,position){if(!this.el){this.el=document.createElement('label');this.el.id=this.getId();this.el.innerHTML=this.text?Ext.util.Format.htmlEncode(this.text):(this.html||'');if(this.forId){this.el.setAttribute('for',this.forId);}}
Ext.form.Label.superclass.onRender.call(this,ct,position);},setText:function(t,encode){this.text=t;if(this.rendered){this.el.dom.innerHTML=encode!==false?Ext.util.Format.htmlEncode(t):t;}
return this;}});Ext.reg('label',Ext.form.Label);