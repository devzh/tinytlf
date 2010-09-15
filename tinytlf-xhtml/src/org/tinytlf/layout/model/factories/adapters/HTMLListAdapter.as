package org.tinytlf.layout.model.factories.adapters
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
				return Terminators.terminateBefore(listElement);
			}
			else
			{
				return listElement;
			}
        }
    }
}