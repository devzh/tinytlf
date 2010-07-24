/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.extensions.styles.fcss
{
    import com.flashartofwar.fcss.applicators.StyleApplicator;
    import com.flashartofwar.fcss.styles.IStyle;
    import com.flashartofwar.fcss.stylesheets.FStyleSheet;

    import flash.text.engine.*;
    import flash.utils.Dictionary;

    import org.tinytlf.extensions.core.fcss.FStyleProxy;
    import org.tinytlf.styles.TextStyler;
    import org.tinytlf.utils.XMLUtil;

    public class FCSSTextStyler extends TextStyler
    {
        override public function set style(value:Object):void
        {
            if (value is String)
            {
                var sheet:FStyleSheet = new FStyleSheet();
                sheet.parseCSS(value as String);
                value = new FStyleProxy(sheet);
            }

            super.style = value;
        }

        override public function getElementFormat(element:*):ElementFormat
        {
            if (!(element is Array) || !(style is FStyleProxy))
                return super.getElementFormat(element);

            var fStyle:IStyle = computeStyles(element as Array);

            var format:ElementFormat = new ElementFormat();
            new StyleApplicator().applyStyle(format, fStyle);
            var description:FontDescription = new FontDescription();
            new StyleApplicator().applyStyle(description, fStyle);

            format.fontDescription = description;

            return format;
        }

        override public function describeElement(element:*):Object
        {
            if (!(style is FStyleProxy))
                return super.describeElement(element);

            var context:Array = (element as Array) || [element];
            var obj:Object = super.describeElement(context[context.length - 1].localName()) || {};

            var fStyle:IStyle = computeStyles(context);
            for (var styleProp:String in fStyle)
                obj[styleProp] = fStyle[styleProp];

            obj['style'] = fStyle;

            return obj;
        }

        protected var nodeCache:Dictionary = new Dictionary(true);

        protected function computeStyles(context:Array):IStyle
        {
            //  Context is the currently processing XML node 
            //  and its parents, with attributes.

            var node:XML;
            var attributes:Object;
            var attr:String;

            var i:int = 0;
            var n:int = context.length;

            var className:String;
            var idName:String;
            var uniqueNodeName:String;
            var inlineStyle:String = 'a:a;';
            var inheritanceStructure:Array = ['global'];

            var str:String = '';

            for (i = 0; i < n; i++)
            {
                node = context[i];

                if (!(node in nodeCache))
                {
                    if (node.localName())
                        str += node.localName();

                    if (node.attributes().length())
                    {
                        attributes = XMLUtil.buildKeyValueAttributes(node.attributes());

                        //  Math.random() times one trillion. Reasonably safe for unique identification... right? ;)
                        uniqueNodeName = ' ' + node.localName() + String(Math.round(Math.random() * 100000000000000));

                        for (attr in attributes)
                        {
                            if (attr == 'class')
                                className = attributes[attr];
                            else if (attr == 'id')
                                idName = attributes[attr];
                            else if (attr == 'style')
                                inlineStyle += attributes[attr];
                            else if(attr == 'cssState' && attributes[attr] != '')
                                str += ':' + attributes[attr];
                            else if (attr != 'unique')
                                inlineStyle += (attr + ': ' + attributes[attr] + ";");
                        }
                    }

                    if (className)
                        str += " ." + className;
                    if (idName)
                        str += " #" + idName;

                    str += uniqueNodeName;

                    FStyleProxy(style).sheet.parseCSS(uniqueNodeName + '{' + inlineStyle + '}');

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

        //Statically generate a map of the properties in this object
        generatePropertiesMap(new FCSSTextStyler());
    }
}


