/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.styles
{
    import flash.text.engine.ElementFormat;
    import flash.text.engine.FontDescription;
    import flash.utils.Dictionary;
    
    import org.tinytlf.ITextEngine;
    
    public class TextStyler extends StyleAwareActor implements ITextStyler
    {
        public function TextStyler(styleObject:Object = null)
        {
            super(styleObject);
        }
		
        protected var _engine:ITextEngine;
        public function get engine():ITextEngine
        {
            return _engine;
        }
        
        public function set engine(textEngine:ITextEngine):void
        {
            if(textEngine == _engine)
                return;
            
            _engine = textEngine;
        }
        
        public function getElementFormat(element:*):ElementFormat
        {
            var styleProp:String;
            var format:ElementFormat = new ElementFormat();
            var description:FontDescription = new FontDescription();
            
            for(styleProp in this)
            {
                if(styleProp in format)
                    format[styleProp] = this[styleProp];
                if(styleProp in description)
                    description[styleProp] = this[styleProp];
            }
            
            format.fontDescription = description;
            
            return format;
        }
        
        protected var styleMap:Dictionary = new Dictionary(true);
        
        public function describeElement(element:*):Object
        {
            var obj:IStyleAware = new StyleAwareActor();
            
            if(element in styleMap)
				obj.mergeWith(styleMap[element]);
            
            return obj;
        }
        
        public function mapStyle(element:*, value:*):void
        {
            styleMap[element] = value;
        }
        
        public function unMapStyle(element:*):Boolean
        {
            if(element in styleMap)
                return delete styleMap[element];
            
            return false;
        }
    }
}

