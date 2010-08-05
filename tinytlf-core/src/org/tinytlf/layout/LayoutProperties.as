/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout
{
    import flash.text.engine.TextBlock;

    import org.tinytlf.layout.descriptions.TextAlign;
    import org.tinytlf.layout.descriptions.TextDirection;
    import org.tinytlf.layout.descriptions.TextFloat;
    import org.tinytlf.layout.descriptions.TextTransform;
    
    public class LayoutProperties
    {
        public function LayoutProperties(props:Object = null, block:TextBlock = null)
        {
            if(!props)
                return;
            
            for(var prop:String in props)
                if(prop in this)
                    this[prop] = props[prop];

            this.block = block;
        }
        
        public var block:TextBlock;
        
        public var width:Number = 0;
        public var lineHeight:Number = 0;
        public var textIndent:Number = 0;
        public var paddingLeft:Number = 0;
        public var paddingRight:Number = 0;
        public var paddingBottom:Number = 0;
        public var paddingTop:Number = 0;
        
        public var textAlign:String = TextAlign.LEFT;
        public var textDirection:String = TextDirection.LTR;
        public var textTransform:String = TextTransform.NONE;
        public var float:String = TextFloat.LEFT;
    }
}

