package org.tinytlf.layout.model.factories.xhtml
{
    import flash.text.engine.ContentElement;
    import flash.text.engine.TextBlock;
    
    import org.tinytlf.layout.LayoutProperties;
    import org.tinytlf.layout.model.factories.AbstractLayoutFactoryMap;
    import org.tinytlf.layout.model.factories.IContentElementFactory;
    import org.tinytlf.layout.model.factories.xhtml.adapters.XMLElementAdapter;
    import org.tinytlf.styles.IStyleAware;
    import org.tinytlf.styles.StyleAwareActor;
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
                    xml = new XML("<body><p>" + xml + "</p></body>");
				else
                    ancestorList.push(getXMLDefinition(xml));
            }
            catch(e:Error){
                xml = new XML("<body><p>" + data.toString() + "</p></body>");
                
                if((xml.*[0] as XML).nodeKind() == 'text')
                    xml = new XML("<body>" + xml + "</body>");
            }

            var blocks:Vector.<TextBlock> = new <TextBlock>[];
            var block:TextBlock;
            var element:ContentElement;
			
			ancestorList.push(getXMLDefinition(xml))
			
            for each(var child:XML in xml.*)
            {
                if(child.nodeKind() == 'text')
                {
                    element = getElementFactory(xml.localName()).execute.apply(null, [child.toString()].concat(ancestorList));
                }
                else
                {
                    ancestorList.push(getXMLDefinition(child));
                    element = getElementFactory(child.localName()).execute.apply(null, [child].concat(ancestorList));
                    ancestorList.pop();
                }
				
				var style:IStyleAware = new StyleAwareActor(engine.styler.describeElement([child]));
				
                block = new TextBlock(element);
				
				style.applyStyles(block);
				
                block.userData = new LayoutProperties(style, block);
				
                blocks.push(block);
            }

            return blocks;
        }

        private static const nodePattern:RegExp = /\<[^\/](.*?)\>/;
        private static const endNodePattern:RegExp = /(\/>)|(\>)/;

        override public function getElementFactory(element:*):IContentElementFactory
        {
            if (!(element in elementAdapterMap))
            {
                var adapter:IContentElementFactory = new XMLElementAdapter();
                IContentElementFactory(adapter).engine = engine;
                return adapter;
            }
            
            return super.getElementFactory(element);
        }

        protected function getXMLDefinition(node:XML):XML
        {
            return new XML(String(node.toXMLString().match(nodePattern)[0]).replace(endNodePattern, '/>'));
        }
    }
}

