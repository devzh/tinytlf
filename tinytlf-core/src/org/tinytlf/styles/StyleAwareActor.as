/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.styles
{
    import com.flashartofwar.fcss.objects.AbstractOrderedObject;
    import com.flashartofwar.fcss.styles.IStyle;
    
    import flash.net.registerClassAlias;
    import flash.utils.flash_proxy;
    
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
    public dynamic class StyleAwareActor extends AbstractOrderedObject implements IStyleAware, IStyle
    {
        public function StyleAwareActor(styleObject:Object = null)
        {
			super(this);
			
            if(!styleObject)
                return;
            
            style = styleObject;
        }
        
        public function get style():Object
        {
            return properties;
        }
        
        public function set style(value:Object):void
        {
			if(value === properties)
				return;
			
			merge(value);
			
			if(value is IStyleAware)
			{
				IStyleAware(value).merge(this);
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
		
		public function clone():IStyle
		{
			return new StyleAwareActor(this);
		}
		
		private var _styleName:String = '';
		public function set styleName(value:String):void
		{
			if(value === _styleName)
				return;
			
			_styleName = value;
		}
		
		public function get styleName():String
		{
			return _styleName;
		}
		
		override protected function registerClass():void
		{
			registerClassAlias("org.tinytlf.styles.StyleAwareActor", StyleAwareActor);
		}
    }
}

