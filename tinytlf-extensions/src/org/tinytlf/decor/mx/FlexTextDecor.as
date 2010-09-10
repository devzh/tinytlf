/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.decor.mx
{
    import org.tinytlf.decor.ITextDecoration;
    import org.tinytlf.decor.TextDecor;
    import org.tinytlf.layout.ITextContainer;
    import org.tinytlf.styles.mx.FlexStyleProxy;
    
    public class FlexTextDecor extends TextDecor
    {
        public function FlexTextDecor()
        {
            super();
        }
        
        override public function decorate(element:*, 
										  styleObj:Object, 
										  layer:int = 0, 
										  container:ITextContainer = null, foreground:Boolean = false):void
        {
			//  They can pass in a Flex style selector and we'll grab all the
			//  decoration definitions off of it.
            if(styleObj is String)
			{
                styleObj = new FlexStyleProxy(String(styleObj));
			}
            
            super.decorate(element, styleObj, layer, container);
        }
        
        override public function getDecoration(styleProp:String, 
											   container:ITextContainer = null):ITextDecoration
        {
            var dec:ITextDecoration = super.getDecoration(styleProp, container);
            
            //  Hook this decoration into the Flex StyleManager so that they can 
            //  pull decorations using a Flex style selector.
            if(dec)
			{
                dec.style = new FlexStyleProxy(dec.style);
			}
            
            return dec;
        }
    }
}

