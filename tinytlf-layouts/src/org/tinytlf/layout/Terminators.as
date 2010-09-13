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
		
		public static function getTerminatingElement(terminator:Object):GroupElement
		{
			var graphicFormat:ElementFormat = new ElementFormat(null, 0, 0, 0, 'auto', TextBaseline.IDEOGRAPHIC_TOP);
			var terminatingElement:GraphicElement = new GraphicElement(new Shape(), 0, 0, graphicFormat);
			terminatingElement.userData = terminator;
			
			var breakFormat:ElementFormat = new ElementFormat();
			breakFormat.breakOpportunity = BreakOpportunity.ALL;
			
			return new GroupElement(new <ContentElement>[terminatingElement, new GraphicElement(new Shape(), 0, 0, graphicFormat.clone())], breakFormat);
		}
		
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
	}
}