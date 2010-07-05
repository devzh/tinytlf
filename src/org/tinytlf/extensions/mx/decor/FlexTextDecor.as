/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.extensions.mx.decor
{
    import org.tinytlf.decor.ITextDecoration;
    import org.tinytlf.decor.TextDecor;
    import org.tinytlf.layout.ITextContainer;
    import org.tinytlf.extensions.mx.core.FlexStyleProxy;
    
    public class FlexTextDecor extends TextDecor
    {
        public function FlexTextDecor()
        {
            super();
        }
        
        override public function decorate(element:*, styleObj:Object, layer:int = 0, containers:Vector.<ITextContainer> = null):void
        {
            if(styleObj is String)
                styleObj = new FlexStyleProxy(String(styleObj));
            
            super.decorate(element, styleObj, layer, containers);
        }
        
        override public function getDecoration(styleProp:String, containers:Vector.<ITextContainer> = null):ITextDecoration
        {
            var dec:ITextDecoration = super.getDecoration(styleProp, containers);
            
            //  Hook this decoration into the Flex StyleManager so that they can 
            //  pull decorations using a Flex style selector.
            if(dec)
                dec.style = new FlexStyleProxy(dec.style);
            
            return dec;
        }
    }
}

