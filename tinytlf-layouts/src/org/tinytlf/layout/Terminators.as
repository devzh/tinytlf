package org.tinytlf.layout
{
	import flash.display.Shape;
	import flash.text.engine.BreakOpportunity;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.GraphicElement;
	import flash.text.engine.GroupElement;
	import flash.text.engine.TextBaseline;
	
	public class Terminators
	{
		public static const HTML_LIST:Object = {};
		public static const HTML_LIST_TERMINATOR:Object = {};
		public static const CONTAINER_TERMINATOR:Object = {};
		
		public static function terminateBefore(element:ContentElement, marker:Object = null):GroupElement
		{
			var breakFormat:ElementFormat = new ElementFormat();
			breakFormat.breakOpportunity = BreakOpportunity.ALL;
			
			var graphic:GraphicElement = new GraphicElement(new Shape(), 0, 0, new ElementFormat());
			graphic.userData = marker;
			
			return new GroupElement(new <ContentElement>[graphic, element], breakFormat);
		}
		
		public static function terminateAfter(element:ContentElement, marker:Object = null):GroupElement
		{
			var breakFormat:ElementFormat = new ElementFormat();
			breakFormat.breakOpportunity = BreakOpportunity.ALL;
			
			var graphic:GraphicElement = new GraphicElement(new Shape(), 0, 0, new ElementFormat());
			graphic.userData = marker;
			
			return new GroupElement(new <ContentElement>[element, graphic], breakFormat);
		}
		
		public static function terminateClear(element:ContentElement, markerLeft:Object = null, markerRight:Object = null):GroupElement
		{
			var breakFormat:ElementFormat = new ElementFormat();
			breakFormat.breakOpportunity = BreakOpportunity.ALL;
			
			var start:GraphicElement = new GraphicElement(new Shape(), 0, 0, new ElementFormat());
			start.userData = markerLeft;
			
			var end:GraphicElement = new GraphicElement(new Shape(), 0, 0, new ElementFormat());
			end.userData = markerRight;
			
			return new GroupElement(new <ContentElement>[start, element, end], breakFormat);
		}
	}
}