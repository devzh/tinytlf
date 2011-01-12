/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.styles
{
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import org.tinytlf.util.TinytlfUtil;
	
	use namespace flash_proxy;
	
	/**
	 * StyleAwareActor is a useful base class for objects with sealed properties
	 * but who also wish to dynamically accept and store named values.
	 *
	 * Since it extends Proxy, it overrides the flash_proxy functions for setting
	 * and retrieving data. If you are calling a sealed property on
	 * StyleAwareActor or one of his subclasses, the property or function is called
	 * like normal. However, if you dynamically set or call a property on it,
	 * <code>getStyle</code> and <code>setStyle</code> are called instead.
	 *
	 * StyleAwareActor has a <code>style</code> member, on which the style
	 * properties and values are stored. You can pass in your own dynamic
	 * instance to store styles on by setting the <code>style</code> setter.
	 * This will set the new value as the internal styles storage object, as
	 * well as copy over all the key/value pairs currently on the new instance.
	 *
	 * This is useful if you wish to proxy styles, or to support external styling
	 * implementations (currently Flex and F*CSS).
	 */
	public dynamic class StyleAwareActor extends Proxy implements IStyleAware
	{
		public function StyleAwareActor(styleObject:Object = null)
		{
			if(!styleObject)
				return;
			
			style = styleObject;
		}
		
		protected var properties:Object = {};
		protected var propNames:Array = [];
		
		public function get style():Object
		{
			return properties;
		}
		
		public function set style(value:Object):void
		{
			if(value === properties)
				return;
			
			mergeWith(value);
			
			if(value is IStyleAware)
			{
				IStyleAware(value).mergeWith(this);
				properties = value;
			}
		}
		
		public function clearStyle(styleProp:String):Boolean
		{
			return delete this[styleProp];
		}
		
		public function getStyle(styleProp:String):*
		{
			return this[styleProp];
		}
		
		public function setStyle(styleProp:String, newValue:*):void
		{
			this[styleProp] = newValue;
		}
		
		public function mergeWith(object:Object):void
		{
			for(var prop:String in object)
				mergeProperty(prop, object);
		}
		
		protected function mergeProperty(property:String, source:Object):void
		{
			this[property] = source[property];
		}
		
		public function unmergeWith(object:Object):void
		{
			for(var prop:String in object)
				unmergeProperty(prop);
		}
		
		protected function unmergeProperty(property:String):void
		{
			delete this[property];
		}
		
		public function applyTo(object:Object):void
		{
			for(var prop:String in properties)
				applyProperty(prop, object);
		}
		
		protected function applyProperty(property:String, destination:Object):void
		{
			if(property in destination && !(destination[property] is Function))
				destination[property] = this[property];
		}
		
		public function unapplyTo(object:Object):void
		{
			for(var prop:String in properties)
				unapplyProperty(prop, object);
		}
		
		protected function unapplyProperty(property:String, destination:Object):void
		{
			if(property in destination && !(destination[property] is Function))
				delete destination[property];
		}
		
		public function toString():String
		{
			var styleString:String = "{";
			var i:int;
			var total:int = propNames.length;
			var prop:String;
			for(i = 0; i < total; i++)
			{
				prop = propNames[i];
				styleString = styleString.concat(prop, ":", properties[prop].toString(), ";");
			}
			
			styleString = styleString.concat("}");
			
			return styleString;
		}
		
		override flash_proxy function getProperty(name:*):*
		{
			return properties[name];
		}
		
		override flash_proxy function hasProperty(name:*):Boolean
		{
			return properties.hasOwnProperty(name);
		}
		
		override flash_proxy function callProperty(name:*, ... parameters):*
		{
			if(properties.hasOwnProperty(name))
				return function(... args):*{return properties[name]};
			
			return null;
		}
		
		override flash_proxy function deleteProperty(name:*):Boolean
		{
			if(delete properties[name])
			{
				propNames.splice(propNames.indexOf(name.toString()), 1);
				return true;
			}
			
			return false;
		}
		
		override flash_proxy function setProperty(name:*, value:*):void
		{
			name = TinytlfUtil.stripSeparators(name);
			
			if(!properties.hasOwnProperty(name))
				propNames.push(name.toString());
			
			properties[name] = value;
		}
		
		override flash_proxy function nextName(index:int):String
		{
			return propNames[index - 1];
		}
		
		override flash_proxy function nextNameIndex(index:int):int
		{
			if(index < propNames.length)
				return index + 1;
			else
				return 0;
		}
		
		override flash_proxy function nextValue(index:int):*
		{
			return properties[propNames[index - 1]];
		}
	}
}

