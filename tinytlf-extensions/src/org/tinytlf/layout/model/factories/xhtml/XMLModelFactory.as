package org.tinytlf.layout.model.factories.xhtml
{
	import flash.external.ExternalInterface;
	import flash.text.engine.ContentElement;
	import flash.text.engine.TextBlock;
	
	import org.tinytlf.layout.model.factories.AbstractLayoutFactoryMap;
	import org.tinytlf.layout.model.factories.IContentElementFactory;
	import org.tinytlf.layout.model.factories.xhtml.adapters.XMLElementAdapter;
	import org.tinytlf.layout.properties.LayoutProperties;
	import org.tinytlf.styles.IStyleAware;
	import org.tinytlf.styles.StyleAwareActor;
	
	public class XMLModelFactory extends AbstractLayoutFactoryMap
	{
		override protected function generateTextBlocks():Vector.<TextBlock>
		{
			if (!(data is String) && !(data is XML))
				return super.generateTextBlocks();
			
			var xml:XML;
			
			if(data is XML)
				xml = (data as XML);
			else
			{
				XML.prettyPrinting = false;
				XML.ignoreWhitespace = false;
				xml = new XML('<body>' + slurp(data.toString()) + ' </body>');
			}
			
			var ancestorList:Array = [];
			
			var blocks:Vector.<TextBlock> = new <TextBlock>[];
			var block:TextBlock;
			var element:ContentElement;
			
			for each (var child:XML in xml.*)
			{
				var style:IStyleAware = new StyleAwareActor();
				if (child.nodeKind() == 'text')
				{
					element = getElementFactory(xml.localName()).execute.apply(null, [child.toString()].concat(ancestorList));
				}
				else
				{
					ancestorList.push(getXMLDefinition(child));
					element = getElementFactory(child.localName()).execute.apply(null, [child].concat(ancestorList));
					ancestorList.pop();
					
					style.style = engine.styler.describeElement([getXMLDefinition(child)]);
				}
				
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
		
		private static function slurp(tags:String):String
		{
			//maybe? replace(/\&lt\;/g, '<').replace(/\&rt\;/g, '>').
			return soup(tags.replace(/(\<(\w+))(.*?)(\>|\/\>)/g, function(match:String, node:String, name:String, attributes:String, end:String, ... args):String
			{
				if (end != '/>')
					return match;
				return '<' + name + attributes + '>' + '</' + name + '>';
			}));
		}
		
		private static function soup(tags:String):String
		{
			return ExternalInterface.call('function(tags)\
				{\
					var div = document.createElement("div");\
					div.innerHTML = tags;\
					return div.innerHTML;\
				}', tags);
		}
	}
}

