/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.components.mx
{
    import flash.display.Stage;
    
    import org.tinytlf.TextEngine;
    import org.tinytlf.decor.ITextDecor;
    import org.tinytlf.decor.mx.FlexTextDecor;
    import org.tinytlf.styles.ITextStyler;
    import org.tinytlf.styles.mx.FlexTextStyler;
    
    public class FlexTextEngine extends TextEngine
    {
        public function FlexTextEngine(stage:Stage)
        {
            super(stage);
        }
        
        override public function get decor():ITextDecor
        {
            if(!_decor)
                decor = new FlexTextDecor();
            
            return _decor;
        }
        
        override public function get styler():ITextStyler
        {
            if(!_styler)
                styler = new FlexTextStyler();
            
            return _styler;
        }
    }
}

