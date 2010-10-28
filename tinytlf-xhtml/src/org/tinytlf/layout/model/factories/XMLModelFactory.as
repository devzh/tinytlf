package org.tinytlf.layout.model.factories
{
	import flash.external.ExternalInterface;
	import flash.text.engine.ContentElement;
	import flash.text.engine.TextBlock;
	import flash.utils.Dictionary;
	
	import org.tinytlf.SparseArray;
	import org.tinytlf.layout.model.factories.adapters.XMLElementAdapter;
	import org.tinytlf.layout.properties.LayoutProperties;
	import org.tinytlf.styles.IStyleAware;
	import org.tinytlf.styles.StyleAwareActor;
	import org.tinytlf.util.TinytlfUtil;
	
	public class XMLModelFactory extends AbstractLayoutFactoryMap
	{
		private var list:XMLList = new XMLList();
		private var listIndex:int = 0;
		
		private var cachedElements:Vector.<ContentElement> = new <ContentElement>[];
		private var cachedLayouts:Vector.<LayoutProperties> = new <LayoutProperties>[];
		
		private var sparse:SparseArray = new SparseArray();
		
		//This is an Array because it isn't densly populated.
		private var cachedBlocks:Array = [];
		
		override public function beginRender():void
		{
			visibleBlocks.length = 0;
			
			listIndex = sparse.indexOf(engine.scrollPosition);
			if(listIndex > -1)
				listIndex -= 1;
			
			for(var i:int = listIndex; i > -1; i -= 1)
				if(i in cachedBlocks)
					delete cachedBlocks[i];
		}
		
		override public function endRender():void
		{
			var n:int = list.length();
			for(var i:int = listIndex + 1; i < n; i += 1)
				if(i in cachedBlocks)
					delete cachedBlocks[i];
		}
		
		override public function get nextBlock():TextBlock
		{
			if(++listIndex >= list.length())
				return null;
			
			if(cachedBlocks[listIndex])
			{
				return cachedBlocks[listIndex];
			}
			
			var element:ContentElement;
			var style:IStyleAware = new StyleAwareActor();
			var lp:LayoutProperties;
			var xml:XML = list[listIndex];
			
			if(listIndex in cachedElements)
			{
				element = cachedElements[listIndex];
				lp = cachedLayouts[listIndex];
				if(xml.nodeKind() !== 'text')
				{
					style.style = new StyleAwareActor(
						engine.styler.describeElement(
							new XMLDescription(xml)));
				}
			}
			else
			{
				if(xml.nodeKind() == 'text')
				{
					element = getElementFactory(xml.localName()).execute.apply(null, [xml.toString()]);
				}
				else
				{
					var parent:XMLDescription = new XMLDescription(xml);
					element = getElementFactory(xml.localName()).execute.apply(null, [xml, parent]);
					style.style = new StyleAwareActor(engine.styler.describeElement(parent));
				}
				
				cachedElements[listIndex] = element;
				cachedLayouts[listIndex] = lp = new LayoutProperties(style);
			}
			
			var block:TextBlock = new TextBlock(element);
			lp.merge(block);
			block.userData = lp;
			setupBlockJustifier(block);
			
			return block;
		}
		
		private var layoutCache:Dictionary = new Dictionary(true);
		
		override public function cacheVisibleBlock(block:TextBlock):void
		{
			visibleBlocks.push(block);
			
			if(!(listIndex in layoutCache))
			{
				var lp:LayoutProperties = TinytlfUtil.getLP(block);
				sparse.insert(sparse.length);
				sparse.setItemSize(sparse.length - 1, lp.paddingTop + lp.height + lp.paddingBottom);
				lp.y = sparse.start(sparse.length - 1);
				layoutCache[listIndex] = true;
			}
			
			cachedBlocks[listIndex] = block;
		}
		
		override public function clearCaches():void
		{
			super.clearCaches();
			
			cachedElements.length = 0;
			cachedLayouts.length = 0;
			cachedBlocks = [];
		}
		
		override public function set data(value:Object):void
		{
			if(value is String || value is XML || value is XMLList)
			{
				if(value is XMLList)
				{
					list = XMLList(value);
				}
				else if(value is String)
				{
					var xml:XML;
					XML.prettyPrinting = false;
					XML.ignoreWhitespace = false;
					try{
						xml = new XML(trim(value.toString()));
						if(xml.*.length() == 0)
							xml = <body>{xml}</body>;
					}
					catch(e:Error){
						xml = new XML('<body>' + slurp(value.toString()) + ' </body>');
					}
					
					value = xml;
				}
				if(value is XML)
				{
					list = XML(value).children();
				}
				
				clearCaches();
			}
			
			super.data = value;
		}
		
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
			tags = tags.replace(/<(br|hr|img).*?>/g, '<$1/>');
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
