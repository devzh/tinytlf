package org.tinytlf.extensions.layout.adapter.xml
{
    import flash.text.engine.ContentElement;
    import flash.text.engine.GroupElement;

    import org.tinytlf.layout.adapter.ContentElementAdapter;
    import org.tinytlf.layout.adapter.IContentElementAdapter;
    import org.tinytlf.layout.factory.ILayoutModelFactory;

    public class XMLElementAdapter extends ContentElementAdapter
    {
        override public function execute(data:Object, ...context:Array):ContentElement
        {
            if (data is XML)
            {
                var node:XML = (data as XML);
                
                if (node.nodeKind() == 'text')
                {
                    return super.execute(null, [node.toString()].concat(context));
                }
                
                var name:String = node.localName().toString();

                if (node..*.length() == 1)
                {
                    return blockFactory.getElementAdapter(name).execute.apply(null, [node.text().toString()].concat(context));
                }

                if (node..*.length() > 1)
                {
                    var elements:Vector.<ContentElement> = new <ContentElement>[];
                    var adapter:IContentElementAdapter;

                    for each(var child:XML in node.*)
                    {
                        adapter = blockFactory.getElementAdapter(child.localName());

                        if (child.nodeKind() == "text")
                            elements.push(super.execute.apply(null, [child.toString()].concat(context)));
                        else
                            elements.push(adapter.execute.apply(null, [child].concat(context, getXMLDefinition(child))));
                    }

                    return new GroupElement(elements, getElementFormat(context), getEventMirror(name));
                }
            }

            return super.execute.apply(null, [data].concat(context));
        }

        protected function get blockFactory():ILayoutModelFactory
        {
            return engine.layout.textBlockFactory;
        }

        protected static const nodePattern:RegExp = /<[^\/](.*?)>/;
        protected static const endNodePattern:RegExp = /(\/>)|(>)/;

        protected function getXMLDefinition(node:XML):XML
        {
            return new XML(String(node.toXMLString().match(nodePattern)[0]).replace(endNodePattern, '/>'));
        }
    }
}