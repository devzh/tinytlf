package org.tinytlf.layout.model.factories.xhtml.adapters
{
    import flash.display.DisplayObject;
    import flash.display.Shape;
    import flash.events.EventDispatcher;
    import flash.text.engine.ContentElement;
    import flash.text.engine.ElementFormat;
    import flash.text.engine.GraphicElement;
    import flash.text.engine.GroupElement;
    import flash.text.engine.TextBaseline;
    import flash.text.engine.TextElement;
    
    import spark.primitives.Graphic;
    
    public class HTMLListItemAdapter extends XMLElementAdapter
    {
        override public function execute(data:Object, ... context:Array):ContentElement
        {
            var item:ContentElement = super.execute.apply(null, [data].concat(context));
            
            if(data is XML)
            {
				var styles:Object = engine.styler.describeElement(context);
				var marginLeft:Number = (styles.marginLeft || 25) * getListDepth(context);
				
				var graphic:GraphicElement = new GraphicElement(new Shape(), 
					marginLeft, 1, new ElementFormat(), new EventDispatcher());
				
				engine.decor.decorate(graphic, {bullet:true});
				
                return new GroupElement(new <ContentElement>[
						new TextElement('\n', new ElementFormat(), new EventDispatcher()),
						graphic, item
					]);
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
    public function Bullet(radius:Number = 4, marginLeft:Number = 25)
    {
        graphics.beginFill(0x00, 1);
        graphics.drawCircle(marginLeft + (radius * 2), radius * 2, radius);
		graphics.beginFill(0x00, 0);
		graphics.drawRect(0, 0, marginLeft, 1);
    }
}