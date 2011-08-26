package org.tinytlf.virtualization
{
	import flash.utils.Dictionary;
	
	public class Virtualizer implements IVirtualizer
	{
		private const vector:SparseArray = new SparseArray();
		private const indexCache:Array = [];
		private var itemCache:Dictionary = new Dictionary(false);
		
		public function get size():int
		{
			return vector.length == 0 ? 0 : vector.end(vector.length - 1);
		}
		
		public function get length():int
		{
			return indexCache.length;
		}
		
		public function get items():Array
		{
			return indexCache.concat();
		}
		
		public function clear():void
		{
			vector.length = 0;
			indexCache.length = 0;
			itemCache = new Dictionary(false);
		}
		
		public function add(item:*, size:int):*
		{
			return addAt(item, length, size);
		}
		
		public function addAt(item:*, index:int, size:int):*
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
		
		public function addAtPosition(item:*, position:int, size:int):*
		{
			return addAt(item, getIndexAt(position) + 1, size);
		}
		
		public function setSize(item:*, size:int):*
		{
			return setSizeAt(getIndex(item), size);
		}
		
		public function setSizeAt(index:int, size:int):*
		{
			const item:* = getItemAtIndex(index);
			
			if(!(item || item in itemCache))
				return item;
			
			vector.setItemSize(index, size);
			return item;
		}
		
		public function remove(item:*):*
		{
			return removeAt(getIndex(item));
		}
		
		public function removeAt(index:int):*
		{
			const item:* = getItemAtIndex(index);
			
			if(!(item || item in itemCache))
				return item;
			
			indexCache.splice(index, 1);
			vector.remove(index);
			delete itemCache[item];
			return item;
		}
		
		public function removeAtPosition(position:int):*
		{
			return removeAt(getIndex(getItemAtPosition(position)));
		}
		
		public function getStart(item:*):int
		{
			return vector.start(getIndex(item));
		}
		
		public function getEnd(item:*):int
		{
			return vector.end(getIndex(item));
		}
		
		public function getSize(item:*):int
		{
			return vector.getItemSize(getIndex(item));
		}
		
		public function getIndex(item:*):int
		{
			return indexCache.indexOf(item);
		}
		
		public function getIndexAt(position:int):int
		{
			return vector.indexOf(position);
		}
		
		public function getItemAtIndex(index:int):*
		{
			return indexCache[index];
		}
		
		public function getItemAtPosition(position:int):*
		{
			return getItemAtIndex(getIndexAt(position));
		}
	}
}
