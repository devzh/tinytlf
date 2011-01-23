package org.tinytlf.analytics
{
	import flash.text.engine.TextBlock;
	import flash.utils.Dictionary;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.layout.factories.ITextBlockFactory;
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
		
		public function get numBlocks():int
		{
			return indexCache.length;
		}
		
		public function get contentLength():int
		{
			var index:int = contentVector.length - 1;
			return contentVector.end(index);
		}
		
		public function get pixelLength():int
		{
			var index:int = positionVector.length - 1;
			return positionVector.end(index);
		}
		
		private var indexCache:Array = [];
		private var blockCache:Dictionary = new Dictionary(false);
		
		public function addBlockAt(block:TextBlock, index:int):void
		{
			if(!(block in blockCache))
			{
				indexCache.splice(index, 0, block);
				
				positionVector.insert(index);
				contentVector.insert(index);
			}
			
			blockCache[block] = true;
			
			enqueuePosition(block, index);
			enqueueContent(block, index);
		}
		
		public function removeBlockAt(index:int):void
		{
			if(!(index in indexCache))
				return;
			
			positionVector.remove(index);
			contentVector.remove(index);
			
			var block:TextBlock = indexCache[index];
			TextBlockUtil.checkIn(block);
			
			delete blockCache[block];
			indexCache.splice(index, 1);
		}
		
		public function getBlockIndex(block:TextBlock):int
		{
			return indexCache.indexOf(block);
		}
		
		public function getBlockAt(index:int):TextBlock
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
			
			return getBlockAt(index);
		}
		
		public function blockAtPixel(distance:Number):TextBlock
		{
			var index:int = positionVector.indexOf(distance);
			if(index == -1)
				return null;
			
			return getBlockAt(index);
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
			
			var index:int = getBlockIndex(block);
			return contentVector.start(index);
		}
		
		public function blockPixelStart(block:TextBlock):Number
		{
			if(!(block in blockCache))
				return -1;
			
			var index:int = getBlockIndex(block);
			return positionVector.start(index);
		}
		
		public function blockContentSize(block:TextBlock):int
		{
			if(!(block in blockCache))
				return 0;
			
			var index:int = getBlockIndex(block);
			var size:int = block.content.rawText.length;
			contentVector.setItemSize(index, size);
			
			return size;
		}
		
		public function blockPixelSize(block:TextBlock):Number
		{
			if(!(block in blockCache))
				return 0;
			
			var index:int = getBlockIndex(block);
			return positionVector.getItemSize(index);
		}
		
		public function indexContentStart(atIndex:int):Number
		{
			if(atIndex == 0)
				return 0;
			
			if(atIndex >= contentVector.length)
				return contentLength;
			
			return contentVector.start(atIndex);
		}
		
		public function indexPixelStart(atIndex:int):Number
		{
			if(atIndex == 0)
				return 0;
			
			if(atIndex >= positionVector.length)
				return pixelLength;
			
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
			indexCache.length = 0;
			blockCache = new Dictionary(false);
		}
		
		private function enqueueContent(block:TextBlock, index:int):void
		{
			var blockSize:int = block.content ? block.content.rawText.length : 0;
			
			if(blockSize == 0)
				return;
			
			contentVector.setItemSize(index, blockSize);
		}
		
		private function enqueuePosition(block:TextBlock, index:int):void
		{
			var lp:LayoutProperties = TinytlfUtil.getLP(block);
			var blockSize:Number = lp.paddingTop + lp.height + lp.paddingBottom;
			
			if(blockSize == 0)
				return;
			
			positionVector.setItemSize(index, blockSize);
		}
	}
}