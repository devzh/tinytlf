package org.tinytlf.analytics
{
	import flash.text.engine.TextBlock;
	import flash.utils.Dictionary;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.layout.properties.LayoutProperties;
	import org.tinytlf.util.TinytlfUtil;
	import org.tinytlf.util.fte.TextBlockUtil;
	
	public class TextEngineAnalytics implements ITextEngineAnalytics
	{
		public function TextEngineAnalytics()
		{
			contentVector = new SparseArray();
			positionVector = new SparseArray();
		}
		
		protected var _engine:ITextEngine;
		
		public function get engine():ITextEngine
		{
			return _engine;
		}
		
		public function set engine(textEngine:ITextEngine):void
		{
			if (textEngine == _engine)
				return;
			
			_engine = textEngine;
		}
		
		public function get cachedBlocks():Dictionary
		{
			//TODO: this should probably be read only
			return blockCache;
		}
		
		public function get contentLength():int
		{
			var index:int = contentVector.length - 1;
			return contentVector.end(index);
		}
		
		private var indexCache:Array = [];
		private var blockCache:Dictionary = new Dictionary(false);
		
		public function cacheBlock(block:TextBlock, index:int):void
		{
			enqueuePosition(block, index);
			enqueueContent(block, index);
			
			indexCache[index] = block;
			blockCache[block] = index;
		}
		
		public function uncacheBlock(index:int):void
		{
			if(index in indexCache)
			{
				var block:TextBlock = indexCache[index];
				TextBlockUtil.checkIn(block);
				
				delete blockCache[block];
				delete indexCache[index];
			}
		}
		
		public function clearBlock(index:int):void
		{
			if(!(index in indexCache))
				return;
			
			positionVector.remove(index);
			contentVector.remove(index);
			uncacheBlock(index);
		}
		
		public function blockAtIndex(index:int):TextBlock
		{
			return indexCache[index];
		}
		
		private var contentVector:SparseArray;
		private var positionVector:SparseArray;
		
		public function blockAtContent(index:int):TextBlock
		{
			var index:int = contentVector.indexOf(index);
			if(index == -1)
				return null;
			
			return indexCache[index];
		}
		
		public function blockAtPixel(distance:Number):TextBlock
		{
			var index:int = positionVector.indexOf(distance);
			if(index == -1)
				return null;
			
			return indexCache[index];
		}
		
		public function indexAtContent(index:int):int
		{
			return contentVector.indexOf(index);
		}
		
		public function indexAtPixel(distance:int):int
		{
			return positionVector.indexOf(distance);
		}
		
		public function blockContentStart(block:TextBlock):Number
		{
			if(!(block in blockCache))
				return -1;
			
			var index:int = blockCache[block];
			return contentVector.start(index);
		}
		
		public function blockPixelStart(block:TextBlock):Number
		{
			if(!(block in blockCache))
				return -1;
			
			var index:int = blockCache[block];
			return positionVector.start(index);
		}
		
		public function blockContentSize(block:TextBlock):int
		{
			if(!(block in blockCache))
				return 0;
			
			var index:int = blockCache[block];
			return contentVector.getItemSize(index);
		}
		
		public function blockPixelSize(block:TextBlock):Number
		{
			if(!(block in blockCache))
				return 0;
			
			var index:int = blockCache[block];
			return positionVector.getItemSize(index);
		}
		
		public function indexContentStart(atIndex:int):Number
		{
			return contentVector.start(atIndex);
		}
		
		public function indexPixelStart(atIndex:int):Number
		{
			return positionVector.start(atIndex);
		}
		
		public function indexContentSize(index:int):int
		{
			return contentVector.getItemSize(index);
		}
		
		public function indexPixelSize(index:int):Number
		{
			return positionVector.getItemSize(index);
		}
		
		public function clear():void
		{
			contentVector.clear();
			positionVector.clear();
			indexCache = [];
			blockCache = new Dictionary(false);
		}
		
		private function enqueueContent(block:TextBlock, index:int = 0):void
		{
			var blockSize:int = block.content.rawText.length;
			var blockIndex:int = index || contentVector.length;
			
			if(blockIndex == contentVector.length)
				contentVector.insert(blockIndex);
			
			contentVector.setItemSize(blockIndex, blockSize);
		}
		
		private function enqueuePosition(block:TextBlock, index:int = 0):void
		{
			var lp:LayoutProperties = TinytlfUtil.getLP(block);
			
			var blockSize:Number = lp.paddingTop + lp.height + lp.paddingBottom;
			blockSize ||= 1;
			
			var blockIndex:int = index || positionVector.length;
			
			if(blockIndex == positionVector.length)
				positionVector.insert(blockIndex);
			
			positionVector.setItemSize(blockIndex, blockSize);
		}
	}
}