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
    import org.tinytlf.core.StyleAwareActor;
    
    public class TextStyler extends StyleAwareActor implements ITextStyler
    {
        public function TextStyler(styleObject:Object = null)
        {
            super(styleObject);
            
            if(getStyle('selectionColor') == null)
                setStyle('selectionColor', 0x003399);
            if(getStyle('selectionAlpha') == null)
                setStyle('selectionAlpha', 0.2);
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
        
        public function getDecorations(element:*):Object
        {
            var obj:Object;
            
            if(element in styleMap)
            {
                obj = {};
                var mappedObj:Object = styleMap[element];
                for(var styleProp:String in mappedObj)
                    obj[styleProp] = mappedObj[styleProp];
            }
            
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
        
        //Statically generate a map of the properties in this object
        generatePropertiesMap(new TextStyler());
    }
}

