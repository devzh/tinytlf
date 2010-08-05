package org.tinytlf.layout.model.factories.xhtml.adapters
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.text.engine.ContentElement;
    import flash.text.engine.ElementFormat;
    import flash.text.engine.GroupElement;
    import flash.text.engine.TextElement;
    
    public class HTMLListAdapter extends XMLElementAdapter
    {
        override public function execute(data:Object, ...context:Array):ContentElement
        {
			//Continue parsing the children
            var listElement:ContentElement = super.execute.apply(null, [data].concat(context));
            
			if(data is XML)
			{
				//Sandwich the list element children between two newLines.
				var children:Vector.<ContentElement> = new <ContentElement>[
					new TextElement('\n', new ElementFormat(null, 0), new EventDispatcher())];
				
				children.push(listElement);
				
				children.push(new TextElement('\n', new ElementFormat(null, 0), new EventDispatcher()));
				
	            return new GroupElement(children);
			}
			else
			{
				return listElement;
			}
        }
    }
}