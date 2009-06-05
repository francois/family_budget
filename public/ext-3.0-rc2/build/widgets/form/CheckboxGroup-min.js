/*
 * Ext JS Library 3.0 RC2
 * Copyright(c) 2006-2009, Ext JS, LLC.
 * licensing@extjs.com
 * 
 * http://extjs.com/license
 */


Ext.form.CheckboxGroup=Ext.extend(Ext.form.Field,{columns:'auto',vertical:false,allowBlank:true,blankText:"You must select at least one item in this group",defaultType:'checkbox',groupCls:'x-form-check-group',onRender:function(ct,position){if(!this.el){var panelCfg={cls:this.groupCls,layout:'column',border:false,renderTo:ct};var colCfg={defaultType:this.defaultType,layout:'form',border:false,defaults:{hideLabel:true,anchor:'100%'}}
if(this.items[0].items){Ext.apply(panelCfg,{layoutConfig:{columns:this.items.length},defaults:this.defaults,items:this.items})
for(var i=0,len=this.items.length;i<len;i++){Ext.applyIf(this.items[i],colCfg);};}else{var numCols,cols=[];if(typeof this.columns=='string'){this.columns=this.items.length;}
if(!Ext.isArray(this.columns)){var cs=[];for(var i=0;i<this.columns;i++){cs.push((100/this.columns)*.01);}
this.columns=cs;}
numCols=this.columns.length;for(var i=0;i<numCols;i++){var cc=Ext.apply({items:[]},colCfg);cc[this.columns[i]<=1?'columnWidth':'width']=this.columns[i];if(this.defaults){cc.defaults=Ext.apply(cc.defaults||{},this.defaults)}
cols.push(cc);};if(this.vertical){var rows=Math.ceil(this.items.length/numCols),ri=0;for(var i=0,len=this.items.length;i<len;i++){if(i>0&&i%rows==0){ri++;}
if(this.items[i].fieldLabel){this.items[i].hideLabel=false;}
cols[ri].items.push(this.items[i]);};}else{for(var i=0,len=this.items.length;i<len;i++){var ci=i%numCols;if(this.items[i].fieldLabel){this.items[i].hideLabel=false;}
cols[ci].items.push(this.items[i]);};}
Ext.apply(panelCfg,{layoutConfig:{columns:numCols},items:cols});}
this.panel=new Ext.Panel(panelCfg);this.el=this.panel.getEl();if(this.forId&&this.itemCls){var l=this.el.up(this.itemCls).child('label',true);if(l){l.setAttribute('htmlFor',this.forId);}}
var fields=this.panel.findBy(function(c){return c.isFormField;},this);this.items=new Ext.util.MixedCollection();this.items.addAll(fields);}
Ext.form.CheckboxGroup.superclass.onRender.call(this,ct,position);},afterRender:function(){Ext.form.CheckboxGroup.superclass.afterRender.call(this);if(this.values){this.setValue.apply(this,this.values);delete this.values;}},validateValue:function(value){if(!this.allowBlank){var blank=true;this.items.each(function(f){if(f.checked){return blank=false;}},this);if(blank){this.markInvalid(this.blankText);return false;}}
return true;},onDisable:function(){this.items.each(function(item){item.disable();})},onEnable:function(){this.items.each(function(item){item.enable();})},onResize:function(w,h){this.panel.setSize(w,h);this.panel.doLayout();},reset:function(){Ext.form.CheckboxGroup.superclass.reset.call(this);this.items.each(function(c){if(c.reset){c.reset();}},this);},setValue:function(id,value){if(this.rendered){if(arguments.length==1){if(Ext.isArray(id)){Ext.each(id,function(val,idx){var item=this.items.itemAt(idx);if(item){item.setValue(val);}},this);}else if(Ext.isObject(id)){for(var i in id){var f=this.getBox(i);if(f){f.setValue(id[i]);}}}}else{var f=this.getBox(id);if(f){f.setValue(value);}}}else{this.values=arguments;}},getBox:function(id){var box=null;this.items.each(function(f){if(id==f||f.dataIndex==id||f.id==id||f.getName()==id){box=f;return false;}},this);return box;},getValue:function(){var out=[];if(this.items){this.items.each(function(item){if(item.checked){out.push(item);}});}
return out;},initValue:Ext.emptyFn,getValue:Ext.emptyFn,getRawValue:Ext.emptyFn,setRawValue:Ext.emptyFn});Ext.reg('checkboxgroup',Ext.form.CheckboxGroup);