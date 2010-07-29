package org.tinytlf.extensions.layout.adapter.xml.html
{
    import flash.display.DisplayObject;
    import flash.events.EventDispatcher;
    import flash.text.engine.ContentElement;
    import flash.text.engine.ElementFormat;
    import flash.text.engine.GraphicElement;
    import flash.text.engine.GroupElement;
    import flash.text.engine.TextBaseline;
    import flash.text.engine.TextElement;
    
    import org.tinytlf.extensions.layout.adapter.xml.XMLElementAdapter;
    
    public class HTMLListItemAdapter extends XMLElementAdapter
    {
        override public function execute(data:Object, ... context:Array):ContentElement
        {
            var item:ContentElement = super.execute.apply(null, [data].concat(context));
            
            if(data is XML)
            {
                var numTabs:int = getListDepth(context);
                
                var tabs:String = '';
                for(var i:int = 0; i < numTabs; ++i)
                {
                    tabs += '\t';
                }
                
                var elements:Vector.<ContentElement> = new Vector.<ContentElement>();
                elements.push(new TextElement(tabs, new ElementFormat(), new EventDispatcher()));
                
                var format:ElementFormat = getElementFormat(context);
                format.alignmentBaseline = TextBaseline.IDEOGRAPHIC_CENTER;
                
                var bullet:DisplayObject = new Bullet();
                
                elements.push(new GraphicElement(bullet, bullet.width * 2, bullet.height, format, new EventDispatcher()));
                elements.push(item);
                elements.push(new TextElement('\n', new ElementFormat(), new EventDispatcher()));
                
                return new GroupElement(elements);
            }
            else
            {
                return item;
            }
        }
        
        protected function getListDepth(context:Array):int
        {
            var numListParents:int = 0;
            var i:int = context.length - 1;
            var xml:XML;
            
            for(; i >= 0; --i)
            {
                xml = context[i];
                if(xml.localName().toString() === 'ul')
                    ++numListParents;
            }
            
            return numListParents;
        }
    }
}
import flash.display.Shape;

internal class Bullet extends Shape
{
    public function Bullet(radius:Number = 4)
    {
        graphics.beginFill(0x00, 1);
        graphics.drawCircle(radius * 2, radius * 2, radius);
    }
}