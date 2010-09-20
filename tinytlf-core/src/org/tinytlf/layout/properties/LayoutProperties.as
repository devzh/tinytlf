/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout.properties
{
    import flash.text.engine.TextBlock;
    
    import org.tinytlf.styles.StyleAwareActor;
    
    public class LayoutProperties extends StyleAwareActor
    {
        public function LayoutProperties(props:Object = null, block:TextBlock = null)
        {
            this.block = block;
			
			for(var prop:String in props)
				if(prop in this && !(this[prop] is Function))
					this[prop] = props[prop];
        }
        
        public var block:TextBlock;
        
        public var width:Number = NaN;
        public var height:Number = NaN;
        public var leading:Number = 0;
        public var textIndent:Number = 0;
        public var paddingLeft:Number = 0;
        public var paddingRight:Number = 0;
        public var paddingBottom:Number = 0;
        public var paddingTop:Number = 0;
        
        public var textAlign:String = TextAlign.LEFT;
        public var textDirection:String = TextDirection.LTR;
        public var textTransform:String = TextTransform.NONE;
        public var float:String = '';
		public var letterSpacing:Boolean = false;
		public var locale:String = 'en';
    }
}

