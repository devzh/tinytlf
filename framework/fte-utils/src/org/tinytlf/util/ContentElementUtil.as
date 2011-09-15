package org.tinytlf.util
{
	import flash.display.*;
	import flash.geom.*;
	import flash.text.engine.*;
	
	public final class ContentElementUtil
	{
		/**
		 * Returns all the lines that render the supplied ContentElement.
		 */
		public static function getTextLines(element:ContentElement):Vector.<TextLine>
		{
			const lines:Vector.<TextLine> = new <TextLine>[];
			const block:TextBlock = element.textBlock;
			
			if(!block)
				return lines;
			
			const endIndex:int = element.textBlockBeginIndex + element.rawText.length;
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
			var regions:Vector.<TextLineMirrorRegion> = new <TextLineMirrorRegion>[];
			
			getTextLines(element).
				forEach(function(line:TextLine, ... args):void {
					const tlmrs:Vector.<TextLineMirrorRegion> = line.mirrorRegions || new Vector.<TextLineMirrorRegion>();
					regions = regions.concat(tlmrs.filter(function(tlmr:TextLineMirrorRegion, ... args):Boolean {
						return tlmr.mirror === element.eventMirror;
					}));
				});
			
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
			var graphic:GraphicElement = getLineBreakGraphic(marker, 0xFF0000);
			return new GroupElement(new <ContentElement>[graphic, element], breakAllEF);
		}
		
		/**
		 * Creates a GroupElement which has a line break after the input
		 * ContentElement.
		 */
		public static function lineBreakAfter(element:ContentElement, marker:Object = null):GroupElement
		{
			var graphic:GraphicElement = getLineBreakGraphic(marker, 0x0000FF);
			return new GroupElement(new <ContentElement>[element, graphic], breakAllEF);
		}
		
		/**
		 * Creates a GroupElement which has line breaks before and after the
		 * input ContentElement.
		 */
		public static function lineBreakBeforeAndAfter(element:ContentElement,
													   markerLeft:Object = null,
													   markerRight:Object = null):GroupElement
		{
			var start:GraphicElement = getLineBreakGraphic(markerLeft, 0xFF0000);
			var end:GraphicElement = getLineBreakGraphic(markerRight, 0x0000FF);
			return new GroupElement(new <ContentElement>[start, element, end], breakAllEF);
		}
		
		private static function get breakAllEF():ElementFormat
		{
			var ef:ElementFormat = new ElementFormat();
			ef.breakOpportunity = BreakOpportunity.ALL;
			return ef;
		}
		
		public static function getLineBreakGraphic(marker:Object = null, color:uint = 0xFFFFFF):GraphicElement
		{
			const ef:ElementFormat = new ElementFormat();
			ef.dominantBaseline = TextBaseline.IDEOGRAPHIC_TOP;
			
			var s:Shape = new Shape();
//			s.graphics.beginFill(color);
//			s.graphics.drawRect(0, 0, 10, 2);
//			s.graphics.endFill();
			
			const g:GraphicElement = new GraphicElement(s, 0, 0, ef);
			g.userData = marker;
			
			return g;
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
		
		public static function addChild(parent:ContentElement, child:ContentElement):ContentElement
		{
			if(!(parent is GroupElement))
				return child;
			
			var group:GroupElement = GroupElement(parent);
			return addChildAt(group, child, group.elementCount);
		}
		
		public static function addChildAt(parent:ContentElement, child:ContentElement, index:int):ContentElement
		{
			if(!(parent is GroupElement))
				return child;
			
			var group:GroupElement = GroupElement(parent);
			var elements:Vector.<ContentElement> = getChildren(group);
			
			if(elements.indexOf(child) != -1)
				removeChild(group, child);
			
			elements.splice(index, 0, child);
			group.setElements(elements);
			
			return child;
		}
		
		public static function removeChild(parent:ContentElement, child:ContentElement):ContentElement
		{
			if(!(parent is GroupElement))
				return child;
			
			var group:GroupElement = GroupElement(parent);
			return removeChildAt(group, group.getElementIndex(child));
		}
		
		public static function removeChildAt(parent:ContentElement, index:int):ContentElement
		{
			if(!(parent is GroupElement))
				return null;
			
			var group:GroupElement = GroupElement(parent);
			var child:ContentElement = group.getElementAt(index);
			group.replaceElements(index, index + 1, null);
			
			return child;
		}
		
		public static function removeChildren(parent:ContentElement):Vector.<ContentElement>
		{
			if(!(parent is GroupElement))
				return null;
			
			var group:GroupElement = GroupElement(parent);
			var children:Vector.<ContentElement> = new <ContentElement>[];
			
			while(group.elementCount)
				children.push(removeChildAt(group, group.elementCount));
			
			return children;
		}
		
		public static function getChildren(group:GroupElement):Vector.<ContentElement>
		{
			var n:int = group.elementCount;
			var elements:Vector.<ContentElement> = new <ContentElement>[];
			for(var i:int = 0; i < n; i += 1)
			{
				elements.push(group.getElementAt(i));
			}
			
			return elements;
		}
		
		public static function getLeaf(element:ContentElement, index:int):ContentElement
		{
			if(element is GroupElement && index >= 0)
			{
				element = GroupElement(element).getElementAtCharIndex(index);
				return getLeaf(element, index - element.textBlockBeginIndex);
			}
			
			return element;
		}
	}
}
