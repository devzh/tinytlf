package org.tinytlf.layout.model.factories.xhtml.adapters
{
    import flash.display.Graphics;
    import flash.display.Shape;
    import flash.text.engine.ContentElement;
    import flash.text.engine.ElementFormat;
    import flash.text.engine.GraphicElement;
    import flash.text.engine.GroupElement;
    
    import org.tinytlf.layout.Terminators;
    
    public class HTMLListAdapter extends XMLElementAdapter
    {
        override public function execute(data:Object, ...context:Array):ContentElement
        {
			//Continue parsing the children
            var listElement:ContentElement = super.execute.apply(null, [data].concat(context));
            
			if(data is XML)
			{
				var styles:Object = engine.styler.describeElement(context);
				
				if(styles.listStylePosition === 'outside')
				{
					var marginLeft:Number = styles.marginLeft || 25;
					var gfx:Shape = new Shape();
					gfx.graphics.beginFill(0x00, 0);
					gfx.graphics.drawRect(0, 0, marginLeft, 100000);
					var graphic:GraphicElement = new GraphicElement(gfx, marginLeft, 0, new ElementFormat());
					graphic.userData = Terminators.HTML_LIST;
					
					var group:GroupElement = new GroupElement(new <ContentElement>[
						Terminators.terminateBefore(graphic),
						listElement
						]);
					
					return Terminators.terminateAfter(group, Terminators.HTML_LIST_TERMINATOR);
				}
				else
				{
		            return new GroupElement(new <ContentElement>[Terminators.getTerminatingElement({}), listElement]);
				}
			}
			else
			{
				return listElement;
			}
        }
    }
}