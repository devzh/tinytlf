package org.tinytlf.layout.factories
{
	import flash.external.ExternalInterface;
	import flash.text.engine.*;
	import flash.utils.Dictionary;
	
	import org.tinytlf.SparseArray;
	import org.tinytlf.layout.properties.LayoutProperties;
	import org.tinytlf.styles.*;
	import org.tinytlf.util.TinytlfUtil;
	import org.tinytlf.util.fte.*;
	
	public class XMLTextBlockFactory extends TextBlockFactoryBase
	{
		override public function get nextBlock():TextBlock
		{
			if(++listIndex < list.length())
				return generateTextBlock(listIndex);
			
			return null;
		}
		
		override public function endRender():void
		{
			super.endRender();
			
			//De-cache any blocks after the end index.
			var j:int = -1;
			var n:int = list.length();
			for(var i:int = listIndex + 1; i < n; i += 1)
			{
				if(i in cachedBlocks)
				{
					j = visibleBlocks.indexOf(cachedBlocks[i]);
					if(j != -1)
						visibleBlocks.splice(j, 1);
					
					TextBlockUtil.cleanBlock(TextBlock(cachedBlocks[i]));
					
					delete cachedBlocks[i];
				}
			}
		}
		
		override public function clearCaches():void
		{
			super.clearCaches();
			
			cachedLayouts.length = 0;
		}
		
		override public function getElementFactory(element:*):IContentElementFactory
		{
			if(!(element in elementAdapterMap))
			{
				var adapter:IContentElementFactory = new XMLElementFactory();
				IContentElementFactory(adapter).engine = engine;
				return adapter;
			}
			
			return super.getElementFactory(element);
		}
		
		override public function set data(value:Object):void
		{
			if(value is String || value is XML || value is XMLList)
			{
				// If the valus is already an XMLList, awesome. Don't have to do
				// anything extra.
				if(value is XMLList)
				{
					list = XMLList(value);
				}
				// Otherwise, if the value is a String, try to convert it to an
				// XML object. Once it's a XML, we extract its children below.
				else if(value is String)
				{
					var xml:XML;
					XML.prettyPrinting = false;
					XML.ignoreWhitespace = false;
					try
					{
						xml = new XML(trim(value.toString()));
						if(xml.*.length() == 0)
							xml = <body>{xml}</body>;
					}
					catch(e:Error)
					{
						xml = new XML('<body>' + slurp(value.toString()) + ' </body>');
					}
					
					value = xml;
				}
				
				// Note the lack of an "else if" statement here.
				if(value is XML)
				{
					list = XML(value).children();
				}
				
				// If we're setting new data, clear the caches.
				clearCaches();
				cachedElements.length = 0;
			}
			
			super.data = value;
		}
		
		private var list:XMLList = new XMLList();
		private var cachedElements:Vector.<ContentElement> = new <ContentElement>[];
		private var cachedLayouts:Vector.<LayoutProperties> = new <LayoutProperties>[];
		
		override protected function generateTextBlock(index:int):TextBlock
		{
			//If the block is cached, return it first.
			var block:TextBlock = super.generateTextBlock(index);
			var lp:LayoutProperties;
			
			if(block)
			{
				lp = cachedLayouts[index];
				lp.y = blockPositions.start(index);
				return block;
			}
			
			var element:ContentElement;
			var style:IStyleAware = new StyleAwareActor();
			var xml:XML = list[index];
			
			// If the TextBlock isn't cached, check to see if this item has been
			// parsed before. If so, regenerate its styles (they may have 
			// changed) and return it.
			if(index in cachedElements)
			{
				element = cachedElements[index];
				
				if(xml.nodeKind() !== 'text')
					style.style = new StyleAwareActor(engine.styler.describeElement(new XMLDescription(xml)));
				
				if(index in cachedLayouts)
					lp = cachedLayouts[index];
				else
					cachedLayouts[index] = lp = new LayoutProperties(style);
				
				lp.y = blockPositions.start(index);
			}
			// Otherwise, this item hasn't been parsed before, so run it through
			// the XML parsing routine.
			else
			{
				// The top-level node may only be text. If this is the case, use
				// pass the XML tag as the data for the 
				// IContentElementFactory.execute method.
				if(xml.nodeKind() == 'text')
				{
					element = getElementFactory(xml.localName()).execute.apply(null, [xml.toString()]);
				}
				// If the top-level node isn't strictly a text node, pass the
				// XML object as the data, and an XMLDescription in the ...rest
				// arguments for IContentElementFactory.execute.
				// This call should be recursive, with more calls to the
				// getElementFactory down the line.
				else
				{
					var parent:XMLDescription = new XMLDescription(xml);
					element = getElementFactory(xml.localName()).execute.apply(null, [xml, parent]);
					style.style = new StyleAwareActor(engine.styler.describeElement(parent));
				}
				
				// Cache the results of these (rather expensive) operations.
				cachedElements[index] = element;
				cachedLayouts[index] = lp = new LayoutProperties(style);
			}
			
			// Generate a new TextBlock... I wish I could pool these, but I've
			// run into super funky errors with the FTE when I do. Things like
			// the textBlockBeginIndex of a TextLine being set to 0xFFFFFF.
			// So yeah, not OK.
			block = new TextBlock(element);
			// Apply the properties of this layout element to the TextBlock.
			// This also sets up the TextBlock justifier.
			lp.applyTo(block);
			block.userData = lp;
			
			return block;
		}
		
		/**
		 * Trims out the excess white space that is potentially in XML before
		 * parsing, since we still want to respect at least one white space.
		 *
		 */
		private static function trim(input:String):String
		{
			return input.replace(/\n|\r|\t/g, ' ').replace(/>(\s\s+)</g, '><').replace(/(\s\s+)/g, ' ');
		}
		
		/**
		 * Slurp de soup, but do some translation on self-terminating nodes
		 * before and after slurpage, because the browser doesn't understand
		 * self-terminating nodes, and also because it passes back potentially
		 * invalid XML, but reasonably valid HTML.
		 *
		 */
		private static function slurp(tags:String):String
		{
			//Replace self terminating nodes with open/close pairs
			//e.g.: <node some="attributes"/> to <node some="attributes"></node>
			tags = tags.replace(/<[^>\S]*([^>\s|br|hr|img]+)([^>]*)\/[^>\S]*>/g, '<$1$2></$1>');
			tags = soup(tags);
			tags = tags.replace(/<(br|hr|img).*?>/g, "<$1/>");
			return trim(tags);
		}
		
		/**
		 * @private
		 * Attempts to parse the input malformed XML tags with the browser
		 * through an ExternalInterface call.
		 *
		 */
		private static function soup(tags:String):String
		{
			//Are we running in the browser?
			if(ExternalInterface.available)
			{
				return ExternalInterface.call('function(tags)\
					{\
						var div = document.createElement("div");\
						div.innerHTML = tags;\
						return div.innerHTML;\
					}', tags);
			}
			
			return tags;
		}
	}
}
