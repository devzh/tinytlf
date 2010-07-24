package org.tinytlf.extensions.layout.factory.xml
{
    import flash.text.engine.ContentElement;
    import flash.text.engine.TextBlock;

    import org.tinytlf.extensions.layout.adapter.xml.XMLElementAdapter;
    import org.tinytlf.layout.LayoutProperties;
    import org.tinytlf.layout.adapter.ContentElementAdapter;
    import org.tinytlf.layout.adapter.IContentElementAdapter;
    import org.tinytlf.layout.factory.AbstractLayoutModelFactory;
    import org.tinytlf.utils.XMLUtil;

    public class XMLBlockFactory extends AbstractLayoutModelFactory
    {
        XML.ignoreWhitespace = false;

        override protected function generateTextBlocks():Vector.<TextBlock>
        {
            if(!(data is String) && !(data is XML))
                return super.generateTextBlocks();

            var xml:XML;
            var ancestorList:Array = [];

            try{
                xml = XML(data);
                if(xml.nodeKind() == 'text')
                    xml = new XML("<_><p>" + xml + "</p></_>");
                else
                    ancestorList.push(getXMLDefinition(xml));
            }
            catch(e:Error){
                xml = new XML("<_>" + data.toString() + "</_>");
            }

            var blocks:Vector.<TextBlock> = new <TextBlock>[];
            var block:TextBlock;
            var element:ContentElement;

            for each(var child:XML in xml.*)
            {
                if(child.nodeKind() == 'text')
                {
                    element = getElementAdapter(xml.localName()).execute.apply(null, [child.toString()].concat(ancestorList));
                }
                else
                {
                    ancestorList.push(getXMLDefinition(child));
                    element = getElementAdapter(child.localName()).execute.apply(null, [child].concat(ancestorList));
                    ancestorList.pop();
                }

                block = new TextBlock(element);
                block.userData = new LayoutProperties(XMLUtil.buildKeyValueAttributes(child.attributes()), block);
                blocks.push(block);
            }

            return blocks;
        }

        private static const nodePattern:RegExp = /\<[^\/](.*?)\>/;
        private static const endNodePattern:RegExp = /(\/>)|(\>)/;

        override public function getElementAdapter(element:*):IContentElementAdapter
        {
            if (!(element in elementAdapterMap))
            {
                var adapter:IContentElementAdapter = new XMLElementAdapter();
                IContentElementAdapter(adapter).engine = engine;
                return adapter;
            }
            
            return super.getElementAdapter(element);
        }

        protected function getXMLDefinition(node:XML):XML
        {
            return new XML(String(node.toXMLString().match(nodePattern)[0]).replace(endNodePattern, '/>'));
        }
    }
}

