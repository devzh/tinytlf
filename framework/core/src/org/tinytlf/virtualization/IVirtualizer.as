package org.tinytlf.virtualization
{
	public interface IVirtualizer
	{
		function get size():int;
		function get length():int;
		function get items():Array;
		
		function clear():void;
		
		function add(item:*, size:int):*;
		function addAt(item:*, index:int, size:int):*;
		function addAtPosition(item:*, position:int, size:int):*;
		
		function setSize(item:*, size:int):*;
		function setSizeAt(index:int, size:int):*;
		
		function remove(item:*):*;
		function removeAt(index:int):*;
		function removeAtPosition(position:int):*;
		
		function getStart(item:*):int;
		function getEnd(item:*):int;
		function getSize(item:*):int;
		
		function getIndex(item:*):int;
		function getIndexAt(position:int):int;
		
		function getItemAtIndex(index:int):*;
		function getItemAtPosition(position:int):*;
	}
}
