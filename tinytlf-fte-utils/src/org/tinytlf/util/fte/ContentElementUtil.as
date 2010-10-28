package org.tinytlf.util.fte
{
	import flash.display.Shape;
	import flash.geom.Rectangle;
	import flash.text.engine.*;
	
	public class ContentElementUtil
	{
		/**
		 * Returns all the lines that render the supplied ContentElement.
		 */
		public static function getTextLines(element:ContentElement):Vector.<TextLine>
		{
			var lines:Vector.<TextLine> = new Vector.<TextLine>();
			var block:TextBlock = element.textBlock;
			
			if(!block)
				return lines;
			
			var endIndex:int = element.textBlockBeginIndex + element.rawText.length;
			var line:TextLine = block.getTextLineAtCharIndex(element.textBlockBeginIndex);
			
			while(line && line.textBlockBeginIndex < endIndex)
			{
				lines.push(line);
				line = line.nextLine;
			}
			
			return lines;
		}
		
		/**
		 * Returns a Vector of TextLineMirrorRegions for the ContentElement.
		 */
		public static function getMirrorRegions(element:ContentElement):Vector.<TextLineMirrorRegion>
		{
			var lines:Vector.<TextLine> = getTextLines(element);
			var line:TextLine;
			
			var regions:Vector.<TextLineMirrorRegion> = new Vector.<TextLineMirrorRegion>();
			var tlmrs:Vector.<TextLineMirrorRegion>;
			var tlmr:TextLineMirrorRegion;
			
			while(lines.length)
			{
				line = lines.pop();
				tlmrs = line.mirrorRegions;
				
				if(line.validity != TextLineValidity.VALID || !tlmrs)
					continue;
				
				tlmrs = tlmrs.concat();
				
				while(tlmrs.length)
				{
					tlmr = tlmrs.pop();
					if(tlmr.mirror === element.eventMirror)
						regions.push(tlmr);
				}
			}
			
			return regions;
		}
		
		/**
		 * Returns a Vector of Rectangles that represent the area in which the
		 * ContentElement exists on the Stage. This will only return properly
		 * if the ContentElement has an eventMirror set. If the ContentElement
		 * has no eventMirror, FTE doesn't create TextLineMirrorRegions, and 
		 * it's impossible to determine the boundaries of the ContentElement.
		 */
		public static function getBounds(element:ContentElement):Vector.<Rectangle>
		{
			var regions:Vector.<TextLineMirrorRegion> = getMirrorRegions(element);
			var bounds:Vector.<Rectangle> = new Vector.<Rectangle>();
			var tlmr:TextLineMirrorRegion;
			var rect:Rectangle;
			
			while(regions.length)
			{
				tlmr = regions.pop();
				rect = tlmr.bounds.clone();
				rect.offset(tlmr.textLine.x, tlmr.textLine.y);
				bounds.push(rect);
			}
			
			return bounds;
		}
		
		/**
		 * Creates a GroupElement with two children, a place-holder GraphicElement
		 * and the input ContentElement. The GroupElement has an elementFormat
		 * with breakOpportunity set to "all," which tells the FTE to break
		 * the line between the GroupElement's children, i.e. between the 
		 * placeholder GraphicElement and the input ContentElement.
		 * 
		 * <p>The optional marker parameter is set as the userData property of
		 * the dummy GraphicElement. This allows you to mark/differentiate this
		 * graphic during layout.</p>
		 */
		public static function lineBreakBefore(element:ContentElement, marker:Object = null):GroupElement
		{
			var graphic:GraphicElement = new GraphicElement(new Shape(), 0, 0, new ElementFormat());
			graphic.userData = marker;
			
			var breakFormat:ElementFormat = new ElementFormat();
			breakFormat.breakOpportunity = BreakOpportunity.ALL;
			
			return new GroupElement(new <ContentElement>[graphic, element], breakFormat);
		}
		
		/**
		 * Creates a GroupElement which has a line break after the input
		 * ContentElement.
		 */
		public static function lineBreakAfter(element:ContentElement, marker:Object = null):GroupElement
		{
			var graphicFormat:ElementFormat = new ElementFormat();
			graphicFormat.dominantBaseline = TextBaseline.IDEOGRAPHIC_TOP;
			
			var graphic:GraphicElement = new GraphicElement(new Shape(), 0, 0, graphicFormat);
			graphic.userData = marker;
			
			var breakFormat:ElementFormat = new ElementFormat();
			breakFormat.breakOpportunity = BreakOpportunity.ALL;
			
			return new GroupElement(new <ContentElement>[element, graphic], breakFormat);
		}
		
		/**
		 * Creates a GroupElement which has line breaks before and after the
		 * input ContentElement.
		 */
		public static function lineBreakBeforeAndAfter(element:ContentElement, 
													   markerLeft:Object = null, 
													   markerRight:Object = null):GroupElement
		{
			var graphicFormat:ElementFormat = new ElementFormat();
			graphicFormat.dominantBaseline = TextBaseline.IDEOGRAPHIC_TOP;
			
			var start:GraphicElement = new GraphicElement(new Shape(), 0, 0, graphicFormat);
			start.userData = markerLeft;
			
			var end:GraphicElement = new GraphicElement(new Shape(), 0, 0, graphicFormat.clone());
			end.userData = markerRight;
			
			var breakFormat:ElementFormat = new ElementFormat();
			breakFormat.breakOpportunity = BreakOpportunity.ALL;
			
			return new GroupElement(new <ContentElement>[start, element, end], breakFormat);
		}
		
		
		public static function dumpElement(e:ContentElement, depth:int = 0):String
		{
			var str:String = '';
			var tabs:String = '';
			var j:int = depth;
			
			while(j-- > 0)
			{
				tabs += '\t';
			}
			str += tabs;
			
			if(e is GroupElement)
			{
				++depth;
				
				str += 'GroupElement(\n';
				var n:int = GroupElement(e).elementCount;
				for(var i:int = 0; i < n; ++i)
				{
					str += dumpElement(GroupElement(e).getElementAt(i), depth);
				}
				str += tabs + ')';
			}
			else if(e is TextElement)
			{
				str += 'TextElement("' + TextElement(e).text + '")';
			}
			else if(e is GraphicElement)
			{
				str += 'GraphicElement()';
			}
			
			return str + '\n';
		}
	}
}