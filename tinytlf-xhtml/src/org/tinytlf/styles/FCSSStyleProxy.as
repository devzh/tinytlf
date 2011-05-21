/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.styles
{
	import com.flashartofwar.fcss.styles.IStyle;
	
	import flash.system.Capabilities;
	import flash.utils.flash_proxy;
	
	use namespace flash_proxy;
	
	public class FCSSStyleProxy extends StyleAwareActor implements IStyle
	{
		public function FCSSStyleProxy(styleObject:Object = null)
		{
			super(styleObject);
			
			if(styleObject is IStyle)
			{
				styleName = IStyle(styleObject).styleName;
			}
		}
		
		override protected function mergeProperty(property:String, source:Object):void
		{
			var value:* = source[property];
			
			if(value is String)
			{
				if(valueIsEm(value))
					this[property] = deriveValueFromBaseValue(value, this[property]);
				else if(valueIsPoint(value))
					this[property] = deriveValueFromPoint(value);
				else if(valueIsPercent(value))
					this[property] = deriveValueFromBaseValue(value, this[property]);
				else if(valueIsPixel(value))
					this[property] = deriveValueFromPixel(value);
				else
					super.mergeProperty(property, source);
			}
			else
			{
				super.mergeProperty(property, source);
			}
		}
		
		private var _styleName:String = '';
		
		public function get styleName():String
		{
			return _styleName;
		}
		
		public function set styleName(value:String):void
		{
			if(value === _styleName)
				return;
			
			_styleName = value;
		}
		
		public function clone():IStyle
		{
			return new FCSSStyleProxy(this);
		}
		
		protected function valueIsPoint(value:String):Boolean
		{
			return /pt/i.test(value);
		}
		
		protected function valueIsEm(value:String):Boolean
		{
			return /em/i.test(value);
		}
		
		protected function valueIsPercent(value:String):Boolean
		{
			return /%/i.test(value);
		}
		
		protected function valueIsPixel(value:String):Boolean
		{
			return /px/i.test(value);
		}
		
		protected function deriveValueFromPoint(value:String):Number
		{
			//a point is 1/72nd of an inch.
			return (Number(value.substring(0, value.indexOf('pt'))) / 72) * screenDPI;
		}
		
		protected function deriveValueFromBaseValue(value:String, baseValue:Number = NaN):*
		{
			//If no base value was passed in, we can't derive an M-height.
			if(baseValue != baseValue)
				return value;
			
			return baseValue * Number(value.substring(0, value.indexOf('em')));
		}
		
		protected function deriveValueFromPixel(value:String):Number
		{
			return Number(value.substring(0, value.indexOf('px')));
		}
		
		//Cache the screen DPI.
		protected static const screenDPI:Number = Capabilities.screenDPI;
		
		override flash_proxy function setProperty(name:*, value:*):void
		{
			//Convert any #FFFFFF values to 0xFFFFFF
			if(value is String && String(value).indexOf("#") != -1)
			{
				value = uint('0x' + String(value).substring(1));
			}
			
			super.setProperty(name, value);
		}
		
		public function merge(obj:Object):void
		{
			mergeWith(obj);
			
			if(obj is IStyle)
			{
				styleName = IStyle(obj).styleName;
			}
		}
		
		override public function toString():String
		{
			return styleName + ' ' + super.toString();
		}
	}
}

