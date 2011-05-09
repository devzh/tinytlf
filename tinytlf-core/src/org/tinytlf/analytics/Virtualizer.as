package org.tinytlf.analytics
{
	import flash.utils.Dictionary;
	
	import org.tinytlf.ITextEngine;

	public class Virtualizer implements IVirtualizer
	{
		private var vector:SparseArray = new SparseArray();
		private var indexCache:Array = [];
		private var itemCache:Dictionary = new Dictionary(false);
		
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
		
		public function get size():int
		{
			return vector.end(vector.length - 1);
		}
		
		public function get length():int
		{
			return indexCache.length;
		}
		
		public function get items():Dictionary
		{
			return itemCache;
		}
		
		public function clear():void
		{
			vector = new SparseArray();
			indexCache = [];
			itemCache = new Dictionary(false);
		}
		
		public function enqueue(item:*, size:int):*
		{
			return enqueueAt(item, length, size);
		}
		
		public function enqueueAt(item:*, index:int, size:int):*
		{
			if(item in itemCache)
				return item;
			
			if(size <= 0)
				size = 1;
				
			indexCache.splice(index, 0, item);
			itemCache[item] = true;
			vector.insert(index);
			vector.setItemSize(index, size);
			return item;
		}
		
		public function dequeue(item:*):*
		{
			dequeueAt(getItemIndex(item));
		}
		
		public function dequeueAt(index:int):*
		{
			var item:* = getItemFromIndex(index);
			
			if(!item || !(item in itemCache))
				return item;
			
			indexCache.splice(index, 1);
			vector.remove(index);
			delete itemCache[item];
			
			return item;
		}
		
		public function dequeueAtPosition(position:int):*
		{
			return dequeueAt(getItemIndex(getItemFromPosition(position)));
		}
		
		public function getItemIndex(item:*):int
		{
			return indexCache.indexOf(item);
		}
		
		public function getItemStart(item:*):int
		{
			return vector.start(getItemIndex(item));
		}
		
		public function getItemEnd(item:*):int
		{
			return vector.end(getItemIndex(item));
		}
		
		public function getItemSize(item:*):int
		{
			return vector.getItemSize(getItemIndex(item));
		}
		
		public function getIndexFromPosition(position:int):int
		{
			return vector.indexOf(position);
		}
		
		public function getItemFromPosition(position:int):*
		{
			return getItemFromIndex(getIndexFromPosition(position));
		}
		
		public function getItemFromIndex(index:int):*
		{
			if(index >= length)
				return null;
			
			return indexCache[index];
		}
	}
}