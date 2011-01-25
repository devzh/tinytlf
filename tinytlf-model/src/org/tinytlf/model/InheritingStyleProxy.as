package org.tinytlf.model
{
	import flash.text.engine.ElementFormat;
	import flash.utils.flash_proxy;
	
	import org.tinytlf.styles.ITextStyler;
	import org.tinytlf.styles.StyleAwareActor;
	import org.tinytlf.util.TinytlfUtil;
	
	use namespace flash_proxy;
	
	public class InheritingStyleProxy extends StyleAwareActor
	{
		public function InheritingStyleProxy(owner:ITLFNode)
		{
			this.owner = owner;
		}
		
		private var owner:ITLFNode;
		
		private function isInheritingStyle(name:String):Boolean
		{
			var nonInheritingStyles:Object = owner.engine.styler.getStyle('nonInheritingStyles');
			return !(name in nonInheritingStyles);
		}
		
		// Cache of inherited properties retrieved from the parent tree.
		// Thrown away whenever a call to regenerateStyles() is made, because
		// inheriting properties might have changed. This cache is populated
		// as-needed, e.g. whenever a user requests an inheriting style that
		// isn't cached, the value is cached here for future reference.
		private var inheritedPropertiesCache:Object = {};
		
		private const cssProperties:CSSProperties = new CSSProperties();
		private var cssPropertiesCached:Boolean = false;
		
		public function regenerateStyles():void
		{
			// Throw away cached inherited properties.
			inheritedPropertiesCache = {};
			
			// Throw away cached CSS properties.
			cssProperties.clear();
			cssPropertiesCached = false;
		}
		
		override flash_proxy function getProperty(name:*):*
		{
			if(cssPropertiesCached == false)
			{
				cssPropertiesCached = true;
				generateCSSProperties();
			}
			
			if(name.toString().indexOf(':') != -1)
				return cssProperties[name];
			
			if(name in properties)
				return properties[name];
			
			if(isInheritingStyle(name) && owner.parent)
			{
				if(name in inheritedPropertiesCache)
					return inheritedPropertiesCache[name];
				
				inheritedPropertiesCache[name] = owner.parent[name];
				
				if(inheritedPropertiesCache[name] != undefined)
					return inheritedPropertiesCache[name];
				
				delete inheritedPropertiesCache[name];
			}
			
			if(name in cssProperties)
				return cssProperties[name];
			
			return undefined;
		}
		
		override flash_proxy function setProperty(name:*, value:*):void
		{
			if(cssPropertiesCached == false)
			{
				cssPropertiesCached = true;
				generateCSSProperties();
			}
			
			if(name.toString().indexOf(':') != -1)
			{
				cssProperties[name] = value;
				return;
			}
			
			super.setProperty(name, value);
			
			applyStyle(name, value);
		}
		
		override flash_proxy function hasProperty(name:*):Boolean
		{
			if(cssPropertiesCached == false)
			{
				cssPropertiesCached = true;
				generateCSSProperties();
			}
			
			if(name.toString().indexOf(':') != -1)
				return (name in cssProperties);
			
			if(name in properties)
				return true;
			
			if(isInheritingStyle(name) && owner.parent)
			{
				if(name in inheritedPropertiesCache)
					return true;
				
				inheritedPropertiesCache[name] = owner.parent[name];
				
				if(inheritedPropertiesCache[name] != undefined)
					return true;
				
				delete inheritedPropertiesCache[name];
			}
			
			if(name in cssProperties)
				return true;
			
			return false;
		}
		
		private var inlineStyles:String = '';
		override public function get style():Object
		{
			return inlineStyles;
		}
		
		override public function set style(value:Object):void
		{
			inlineStyles = value.toString();
		}
		
		override public function toString():String
		{
			var s:String = '';
			
			if(inlineStyles)
				s += ' style="' + inlineStyles + '"';
			
			for(var prop:String in properties)
				s += ' ' + prop + '="' + getStyle(prop) + '"';
			
			return s;
		}
		
		private function generateCSSProperties():void
		{
			var styler:ITextStyler = owner.engine.styler;
			var inheritanceTree:String = '* ' + walkStylesTree(owner);
			cssProperties.mergeWith(styler.describeElement(inheritanceTree.split(' ')));
			cssProperties.mergeWith(this);
		}
		
		private function walkStylesTree(owner:ITLFNode):String
		{
			var str:String = '';
			
			if(owner.type == TLFNodeType.CONTAINER)
			{
				str += owner.name;
				
				if('class' in owner)
					str += ' .' + owner['class'];
				if('id' in owner)
					str += ' #' + owner['id'];
			}
			
			return str;
		}
		
		private function applyStyle(name:*, value:*):void
		{
			if(owner.contentElement == null)
				return;
			
			var ef:ElementFormat = owner.contentElement.elementFormat;
			var newEf:ElementFormat = owner.engine.styler.getElementFormat(this);;
			
			//Replace the ElementFormat only if the values are different.
			if(TinytlfUtil.compareObjectValues(ef, newEf, {locked:true}) == false)
				owner.contentElement.elementFormat = ef;
		}
	}
}
import flash.utils.flash_proxy;

import org.tinytlf.styles.StyleAwareActor;

use namespace flash_proxy;

internal class CSSProperties extends StyleAwareActor
{
	public function CSSProperties()
	{
		super(null);
	}
	
	public function clear():void
	{
		properties = {};
	}
	
	override flash_proxy function getProperty(name:*):*
	{
		var propName:String = name.toString();
		var state:String = 'normal:';
		
		if(propName.indexOf(':') != -1)
		{
			state = propName.substring(0, propName.indexOf(':') + 1);
			propName = propName.substr(propName.indexOf(':') + 1);
		}
		
		if(state == 'normal:')
			return super.getProperty(propName);
		
		if(hasState(state))
			return properties[state][propName] || properties[propName];
		
		return properties[propName];
	}
	
	override flash_proxy function setProperty(name:*, value:*):void
	{
		var propName:String = String(name);
		var state:String = 'normal:';
		
		if(propName.indexOf(':') != -1)
		{
			state = propName.substring(0, propName.indexOf(':') + 1);
			propName = propName.substr(propName.indexOf(':') + 1);
		}
		
		if(state == 'normal:')
			return super.setProperty(propName, value);
		
		if(hasState(state))
		{
			properties[state][propName] = value;
			return;
		}
		
		properties[propName] = value;
	}
	
	override flash_proxy function hasProperty(name:*):Boolean
	{
		var propName:String = String(name);
		var state:String = 'normal:';
		
		if(propName.indexOf(':') != -1)
		{
			state = propName.substring(0, propName.indexOf(':') + 1);
			propName = propName.substr(propName.indexOf(':') + 1);
		}
		
		if(state == 'normal:')
			return super.hasProperty(propName);
		
		if(hasState(state))
			return (propName in properties[state]) || (propName in properties);
		
		return (propName in properties);
	}
	
	public function addState(stateName:String):void
	{
		if(hasState(stateName))
			return;
		
		properties[transformStateName(stateName)] = {};
	}
	
	public function hasState(stateName:String):Boolean
	{
		return transformStateName(stateName) in properties;
	}
	
	public function clearState(stateName:String):void
	{
		if(!hasState(stateName))
			return;
		
		delete properties[transformStateName(stateName)];
	}
	
	private function transformStateName(stateName:String):String
	{
		if(stateName.indexOf(':') == -1)
			stateName = stateName + ':';
		
		return stateName;
	}
}