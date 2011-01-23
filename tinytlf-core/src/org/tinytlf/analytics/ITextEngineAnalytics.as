package org.tinytlf.analytics
{
	import flash.text.engine.TextBlock;
	import flash.utils.Dictionary;
	
	import org.tinytlf.ITextEngine;
	
	/**
	 * ITextEngineAnalytics is the framework actor which facilitates and 
	 * supports virtualization. The ITextLayout actor should virtualize the 
	 * visible TextBlocks and should cache/uncache them here.
	 * 
	 * <p>Other parts of the framework can use this class to access information
	 * about the currently visible TextBlocks.
	 * </p>
	 */
	public interface ITextEngineAnalytics
	{
		/**
		 * Reference to the central <code>ITextEngine</code> facade for this
		 * <code>decor</code>.
		 * 
		 * @see org.tinytlf.ITextEngine
		 */
		function get engine():ITextEngine;
		function set engine(textEngine:ITextEngine):void;
		
		function get cachedBlocks():Dictionary;
		function get numBlocks():int;
		function get contentLength():int;
		function get pixelLength():int;
		
		function getBlockAt(index:int):TextBlock;
		function addBlockAt(block:TextBlock, index:int):void;
		function removeBlockAt(index:int):void;
		function getBlockIndex(block:TextBlock):int;
		
		function blockAtContent(index:int):TextBlock;
		function blockContentStart(block:TextBlock):Number;
		function blockContentSize(block:TextBlock):int;
		
		function blockAtPixel(distance:Number):TextBlock;
		function blockPixelStart(block:TextBlock):Number;
		function blockPixelSize(block:TextBlock):Number;
		
		function indexAtContent(index:int):int;
		function indexContentStart(atIndex:int):Number;
		function indexContentSize(index:int):int;
		
		function indexAtPixel(distance:int):int;
		function indexPixelStart(atIndex:int):Number;
		function indexPixelSize(index:int):Number;
		
		function clear():void;
	}
}