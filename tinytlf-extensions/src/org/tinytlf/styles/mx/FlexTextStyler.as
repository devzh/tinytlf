/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.styles.mx
{
    import flash.text.engine.*;
    
    import mx.core.Singleton;
    import mx.styles.CSSStyleDeclaration;
    import mx.styles.IStyleManager2;
    
    import org.tinytlf.styles.TextStyler;
    
    public class FlexTextStyler extends TextStyler
    {
        public function FlexTextStyler()
        {
            super();
            style = new FlexStyleProxy();
        }
        
        private var css:CSSStyleDeclaration;
        
        override public function set style(value:Object):void
        {
            super.style = value;
            
            if(value is String)
            {
                var name:String = String(value);
                if(name.indexOf(".") != 0)
                    name = "." + name;
                
                css = new CSSStyleDeclaration(name);
                
                for(var s:String in properties)
                    css.setStyle(s, properties[s]);
            }
        }
        
        override public function getElementFormat(element:*):ElementFormat
        {
            var mainStyleDeclaration:CSSStyleDeclaration = css || new CSSStyleDeclaration();
            var elementStyleDeclaration:CSSStyleDeclaration = styleManager.getStyleDeclaration(styleMap[element] || "") || new CSSStyleDeclaration();
            
            var reduceBoilerplate:Function = function(style:String, defaultValue:*):*
                {
                    return (elementStyleDeclaration.getStyle(style) || mainStyleDeclaration.getStyle(style) || defaultValue);
                };
            
            //Using primitive values here instead of referencing the constants saves SWC size.
            return new ElementFormat(
                new FontDescription(
                reduceBoilerplate("fontFamily", "_sans"),
                reduceBoilerplate("fontWeight", 'normal'),
                reduceBoilerplate("fontStyle", 'normal'),
                reduceBoilerplate("fontLookup", 'device'),
                reduceBoilerplate("renderingMode", 'cff'),
                reduceBoilerplate("cffHinting", 'horizontalStem')
                ),
                reduceBoilerplate("fontSize", 12),
                reduceBoilerplate("color", 0x0),
                reduceBoilerplate("fontAlpha", 1),
                reduceBoilerplate("textRotation", 'auto'),
                reduceBoilerplate("dominantBaseLine", 'roman'),
                reduceBoilerplate("alignmentBaseLine", 'useDominantBaseline'),
                reduceBoilerplate("baseLineShift", 0.0),
                reduceBoilerplate("kerning", 'on'),
                reduceBoilerplate("trackingRight", 0.0),
                reduceBoilerplate("trackingLeft", 0.0),
                reduceBoilerplate("locale", "en"),
                reduceBoilerplate("breakOpportunity", 'auto'),
                reduceBoilerplate("digitCase", 'default'),
                reduceBoilerplate("digitWidth", 'default'),
                reduceBoilerplate("ligatureLevel", 'common'),
                reduceBoilerplate("typographicCase", 'default')
                );
        }
        
        protected function get styleManager():IStyleManager2
        {
            return Singleton.getInstance("mx.styles::IStyleManager2") as IStyleManager2;
        }
    }
}

