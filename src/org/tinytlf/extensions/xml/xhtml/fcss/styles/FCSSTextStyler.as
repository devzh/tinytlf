/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.extensions.xml.xhtml.fcss.styles
{
    import com.flashartofwar.fcss.applicators.StyleApplicator;
    import com.flashartofwar.fcss.styles.IStyle;
    import com.flashartofwar.fcss.stylesheets.FStyleSheet;
    
    import flash.text.engine.*;
    import flash.utils.Dictionary;
    
    import org.tinytlf.extensions.xml.xhtml.fcss.core.FStyleProxy;
    import org.tinytlf.styles.TextStyler;
    
    public class FCSSTextStyler extends TextStyler
    {
        override public function set style(value:Object):void
        {
            if(value is String)
            {
                var sheet:FStyleSheet = new FStyleSheet();
                sheet.parseCSS(value as String);
                value = new FStyleProxy(sheet);
            }
            
            super.style = value;
        }
        
        private var nodeCache:Dictionary = new Dictionary(true);
        
        override public function getElementFormat(element:*):ElementFormat
        {
            if(!(element is Array) || !(style is FStyleProxy))
                return super.getElementFormat(element);
            
            var fStyle:IStyle = computeStyles(element as Array);
            
            var format:ElementFormat = new ElementFormat();
            new StyleApplicator().applyStyle(format, fStyle);
            var description:FontDescription = new FontDescription();
            new StyleApplicator().applyStyle(description, fStyle);
            
            format.fontDescription = description;
            
            return format;
        }
        
        override public function getDecorations(element:*):Object
        {
            if(!(element is Array) || !(style is FStyleProxy))
                return super.getDecorations(element);
            
            var context:Array = element as Array;
            var obj:Object = super.getDecorations(context[context.length - 1].localName()) || {};
            
            var fStyle:IStyle = computeStyles(context);
            for(var styleProp:String in fStyle)
                obj[styleProp] = fStyle[styleProp];
            
            obj['style'] = fStyle;
            
            return obj;
        }
        
        private function computeStyles(context:Array):IStyle
        {
            //  Context is the currently processing XML node 
            //  and its parents, with attributes.
            
            var node:XML;
            var attributes:XMLList;
            var attr:String;
            
            var i:int = 0;
            var n:int = context.length;
            var j:int = 0;
            var k:int = 0;
            
            var className:String;
            var idName:String;
            var uniqueNodeName:String;
            var inlineStyle:String = 'a:a;';
            var inheritanceStructure:Array = ['global'];
            
            var str:String = '';
            
            for(i = 0; i < n; i++)
            {
                node = context[i];
                attributes = node.attributes();
                
                if(!(node in nodeCache))
                {
                    k = attributes.length();
                    if(node.localName())
                        str += node.localName();
                    
                    if(k > 0)
                    {
                        //  Math.random() * one trillion. Reasonably safe for unique identification... right? ;)
                        uniqueNodeName = ' ' + node.localName() + String(Math.round(Math.random() * 100000000000000));
                        
                        for(j = 0; j < k; j++)
                        {
                            attr = attributes[j].name();
                            
                            if(attr == 'class')
                                className = attributes[j];
                            else if(attr == 'id')
                                idName = attributes[j];
                            else if(attr == 'style')
                                inlineStyle += attributes[j];
                            else if(attr != 'unique')
                                inlineStyle += (attr + ": " + attributes[j] + ";");
                        }
                        
                        if(className)
                            str += " ." + className;
                        if(idName)
                            str += " #" + idName;
                        
                        str += uniqueNodeName;
                        
                        FStyleProxy(style).sheet.parseCSS(uniqueNodeName + '{' + inlineStyle + '}');
                    }
                    nodeCache[node] = str;
                }
                else
                {
                    str = nodeCache[node];
                }
                
                inheritanceStructure = inheritanceStructure.concat(str.split(' '));
                
                str = '';
                className = '';
                idName = '';
                uniqueNodeName = '';
                inlineStyle = 'a:a;';
            }
            
            return FStyleProxy(style).sheet.getStyle.apply(null, inheritanceStructure);
        }
    }
}


