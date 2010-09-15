package org.tinytlf.layout.model.factories
{
	import flash.external.ExternalInterface;
	import flash.text.engine.ContentElement;
	import flash.text.engine.TextBlock;
	
	import org.tinytlf.layout.model.factories.adapters.XMLElementAdapter;
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
				try{
					xml = new XML(trim(data.toString()));
				}
				catch(e:Error){
					xml = new XML('<body>' + slurp(data.toString()) + ' </body>');
				}
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
					ancestorList.push(new XMLDescription(child));
					element = getElementFactory(child.localName()).execute.apply(null, [child].concat(ancestorList));
					ancestorList.pop();
					
					style.style = engine.styler.describeElement(new XMLDescription(child));
				}
				
				block = new TextBlock(element);
				
				style.merge(block);
				
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
		
		//Trims out the excess white space that is potentially in XML before parsing, since
		//we still want to respect at least one white space.
		private static function trim(input:String):String
		{
			return input.replace(/\n|\r|\t/g, '  ').replace(/>\s+</g, '><').replace(/(\s\s+)/g, ' ');
		}
		
		private static function slurp(tags:String):String
		{
			//Replace self terminating nodes with open/close pairs
			//e.g.: <node some="attributes"/> to <node some="attributes"></node>
			tags = tags.replace(/<[^>\S]*([^>\s|br|hr|img]+)([^>]*)\/[^>\S]*>/g, '<$1$2></$1>');
			tags = soup(tags);
			tags = tags.replace(/<(br|hr|img).*?>/g, '<$1/>');
			return tags;
		}
		
		/**
		 * @private
		 * Parses the input malformed XML tags with the
		 */
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

