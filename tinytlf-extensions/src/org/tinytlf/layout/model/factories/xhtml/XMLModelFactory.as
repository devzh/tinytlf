package org.tinytlf.layout.model.factories.xhtml
{
    import flash.text.engine.ContentElement;
    import flash.text.engine.TextBlock;
    
    import org.tinytlf.layout.LayoutProperties;
    import org.tinytlf.layout.model.factories.xhtml.adapters.XMLElementAdapter;
    import org.tinytlf.layout.model.factories.AbstractLayoutFactoryMap;
    import org.tinytlf.layout.model.factories.IContentElementFactory;
    import org.tinytlf.util.XMLUtil;

    public class XMLModelFactory extends AbstractLayoutFactoryMap
    {
        override protected function generateTextBlocks():Vector.<TextBlock>
        {
            if(!(data is String) && !(data is XML))
                return super.generateTextBlocks();

	        XML.ignoreWhitespace = false;
	        XML.prettyPrinting = false;
	
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
                xml = new XML("<p>" + data.toString() + "</p>");
                
                if((xml.*[0] as XML).nodeKind() == 'text')
                    xml = new XML("<_>" + xml + "</_>");
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

        override public function getElementAdapter(element:*):IContentElementFactory
        {
            if (!(element in elementAdapterMap))
            {
                var adapter:IContentElementFactory = new XMLElementAdapter();
                IContentElementFactory(adapter).engine = engine;
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

