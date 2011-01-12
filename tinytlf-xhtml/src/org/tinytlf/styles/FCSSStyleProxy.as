/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.styles
{
	import com.flashartofwar.fcss.styles.IStyle;
	import com.flashartofwar.fcss.utils.TypeHelperUtil;
	
	import flash.system.Capabilities;
	import flash.utils.flash_proxy;
	
	use namespace flash_proxy;
	
	public class FCSSStyleProxy extends StyleAwareActor implements IStyle
	{
		public function FCSSStyleProxy(styleObject:Object = null)
		{
			super(styleObject);
		}
		
		//Properties which can have their values set in em, pt, px, or % sizes.
		protected const specialSizeProperties:Object = {fontSize: true, lineHeight: true, wordSpacing: true, letterSpacing: true};
		
		override protected function mergeProperty(property:String, source:Object):void
		{
			if(property in specialSizeProperties)
			{
				this[property] = deriveFontSizeValue(source[property], this[property]);
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
		
		protected function deriveFontSizeValue(sizeValue:Object, baseFontSize:Number = NaN):Object
		{
			var number:Number = baseFontSize;
			
			if(sizeValue is Number)
			{
				number = Number(sizeValue);
			}
			else if(sizeValue is String)
			{
				var s:String = String(sizeValue);
				if(/pt/i.test(s))
				{
					s = s.substring(0, s.indexOf('pt'));
					//a point is 1/72nd of an inch.
					number = (Number(s) / 72) * screenDPI;
				}
				else if(/em/i.test(s))
				{
					//If no font size was passed in, just store the sizeValue for later.
					if(baseFontSize != baseFontSize)
						return sizeValue;
					
					s = s.substring(0, s.indexOf('em'));
					number = baseFontSize * Number(s);
				}
				else if(/%/i.test(s))
				{
					//If no font size was passed in, just store the sizeValue for later.
					if(baseFontSize != baseFontSize)
						return sizeValue;
					
					s = s.substring(0, s.indexOf('%'));
					number = baseFontSize * Number(s) * .01;
				}
				else
				{
					if(/px/i.test(s))
						s = s.substring(0, s.indexOf('px'));
					
					number = Number(s);
				}
			}
			
			return number;
		}
		
		//Put this here so we're not querying Capabilities every time.
		protected static const screenDPI:Number = Capabilities.screenDPI;
		
		override flash_proxy function setProperty(name:*, value:*):void
		{
			//Convert any #FFFFFF values to 0xFFFFFF
			if(value is String && String(value).indexOf("#") != -1)
				value = TypeHelperUtil.stringToUint(value);
			
			super.setProperty(name, value);
		}
		
		public function merge(obj:Object):void
		{
			mergeWith(obj);
		}
	}
}

