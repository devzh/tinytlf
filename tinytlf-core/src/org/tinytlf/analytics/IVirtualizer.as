package org.tinytlf.analytics
{
	import flash.utils.Dictionary;
	
	import org.tinytlf.ITextEngine;

	public interface IVirtualizer
	{
		/**
		 * Reference to the central <code>ITextEngine</code> facade for this
		 * <code>decor</code>.
		 * 
		 * @see org.tinytlf.ITextEngine
		 */
		function get engine():ITextEngine;
		function set engine(textEngine:ITextEngine):void;
		
		function get size():int;
		function get length():int;
		
		function get items():Dictionary;
		
		function clear():void;
		
		function enqueue(item:*, size:int):*;
		function enqueueAt(item:*, index:int, size:int):*;
		
		function dequeue(item:*):*;
		function dequeueAt(index:int):*;
		function dequeueAtPosition(position:int):*;
		
		function getItemStart(item:*):int;
		function getItemEnd(item:*):int;
		function getItemSize(item:*):int;
		
		function getItemIndex(item:*):int;
		
		function getIndexFromPosition(position:int):int;
		
		function getItemFromPosition(position:int):*;
		function getItemFromIndex(index:int):*;
	}
}