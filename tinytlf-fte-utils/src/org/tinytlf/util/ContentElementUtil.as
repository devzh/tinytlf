package org.tinytlf.util
{
	import flash.geom.Rectangle;
	import flash.text.engine.ContentElement;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineMirrorRegion;
	import flash.text.engine.TextLineValidity;
	
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
	}
}