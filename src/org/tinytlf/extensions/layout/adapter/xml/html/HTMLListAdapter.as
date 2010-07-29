package org.tinytlf.extensions.layout.adapter.xml.html
{
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.text.engine.ContentElement;
    import flash.text.engine.ElementFormat;
    import flash.text.engine.GroupElement;
    import flash.text.engine.TextElement;
    
    import org.tinytlf.extensions.layout.adapter.xml.XMLElementAdapter;
    
    public class HTMLListAdapter extends XMLElementAdapter
    {
        override public function execute(data:Object, ...context:Array):ContentElement
        {
            var listElement:ContentElement = super.execute.apply(null, [data].concat(context));
            
            return new GroupElement(new <ContentElement>[
                new TextElement('\n', new ElementFormat(), new EventDispatcher()),
                listElement]);
        }
    }
}