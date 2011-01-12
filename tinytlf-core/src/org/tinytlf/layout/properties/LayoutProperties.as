/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout.properties
{
    import flash.text.engine.*;
	
    import org.tinytlf.styles.StyleAwareActor;
    
	/**
	 * This class is essentially a struct which stores values that describe the
	 * layout values that should be applied to lines rendered from a TextBlock.
	 * 
	 * This is associated via the TextBlock's <code>userData</code> value, and 
	 * is the only valid value for the <code>userData</code> of a TextBlock in
	 * tinytlf.
	 * 
	 * LayoutProperties is dynamic and extends from the tinytlf styling 
	 * framework, so he's not without extension points. Most of the inline and 
	 * block level layout values are defined as public members, but feel free to
	 * tack on properties as you need.
	 */
    public dynamic class LayoutProperties extends StyleAwareActor
    {
        public function LayoutProperties(props:Object = null)
        {
			super(props);
        }
        
        public var x:Number = 0;
        public var y:Number = 0;
		
        public var width:Number = 0;
        public var height:Number = 0;
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
		public var display:String = TextDisplay.INLINE;
		public var letterSpacing:Boolean = false;
		public var locale:String = 'en';
		
		override protected function applyProperty(property:String, destination:Object):void
		{
			if(property === "textAlign" && destination is TextBlock)
			{
				setupBlockJustifier(TextBlock(destination));
				return;
			}
			
			super.applyProperty(property, destination);
		}
		
		
		/**
		 * Utility method which applies justification properties to the 
		 * TextBlock before it's rendered.
		 */
		protected function setupBlockJustifier(block:TextBlock):void
		{
			var justification:String = LineJustification.UNJUSTIFIED;
			var justifier:TextJustifier = TextJustifier.getJustifierForLocale(locale);
			
			if(textAlign == TextAlign.JUSTIFY)
				justification = LineJustification.ALL_BUT_LAST;
			
			justifier.lineJustification = justification;
			
			if(	!block.textJustifier || 
				block.textJustifier.lineJustification != justification || 
				block.textJustifier.locale != locale)
			{
				applyTo(justifier);
				block.textJustifier = justifier;
			}
		}
    }
}

