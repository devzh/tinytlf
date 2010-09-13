package org.tinytlf.util.fte
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.ContentElement;
	import flash.text.engine.GroupElement;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineMirrorRegion;
	import flash.utils.Dictionary;
	
	public class TextLineUtil
	{
		public static function getAtomIndexAtPoint(line:TextLine, stageCoords:Point):int
		{
			var index:int = line.getAtomIndexAtPoint(stageCoords.x, stageCoords.y);
			
			if (index < 0)
			{
				var bounds:Rectangle = line.getBounds(line.stage);
				var center:Point = bounds.topLeft.clone();
				center.offset(bounds.width * .5, bounds.height * .5);
				
				index = (stageCoords.x < center.x) ? 0 : line.atomCount - 1;
			}
			
			var atomIncrement:int = getAtomSide(line, stageCoords) ? 0 : 1;
			
			return Math.max(index + atomIncrement, 0);
		}
		
		/**
		 * Finds which side of the atom the point is on.
		 * @returns True for left, False for right.
		 */
		public static function getAtomSide(line:TextLine, stageCoords:Point):Boolean
		{
			var atomIndex:int = line.getAtomIndexAtPoint(stageCoords.x, stageCoords.y);
			
			if(atomIndex < 0)
				return true;
			
			var center:Number = line.getAtomCenter(atomIndex);
			var pt:Point = line.localToGlobal(new Point(center));
			
			return pt.x > stageCoords.x;
		}
		
		private static const defaultWordBoundaryPattern:RegExp = /\W+|\b[^\W﷯]*/;
		private static const nonWordPattern:RegExp = /\W/;
		
		public static function getAtomWordBoundary(line:TextLine, atomIndex:int, 
												   left:Boolean = true, boundaryPattern:RegExp = null):int
		{
			if(!boundaryPattern)
				boundaryPattern = defaultWordBoundaryPattern;
			
			if(atomIndex >= line.atomCount)
				atomIndex = line.atomCount - 1;
			else if(atomIndex < 0)
				atomIndex = 0;
			
			var rawText:String = line.textBlock.content.rawText;
			var adjustedIndex:int = line.getAtomTextBlockBeginIndex(atomIndex);
			
			if(nonWordPattern.test(rawText.charAt(adjustedIndex)))
			{
				return atomIndex;
			}
			else
			{
				var text:String = left ?
					rawText.slice(0, adjustedIndex).split("").reverse().join("") :
					rawText.slice(adjustedIndex + 1, rawText.length);
				
				var match:Array = boundaryPattern.exec(text);
				if(match)
				{
					var str:String = String(match[0]);
					atomIndex += nonWordPattern.test(str) ? 0 : str.length * (left ? -1 : 1);
				}
			}
			
			return Math.max(atomIndex, 0);
		}
		
		public static function getElementAtAtomIndex(line:TextLine, atomIndex:int):ContentElement
		{
			var block:TextBlock = line.textBlock;
			var blockBeginIndex:int = line.textBlockBeginIndex;
			var content:ContentElement = block.content;
			while(content is GroupElement)
			{
				content = GroupElement(content).getElementAtCharIndex(blockBeginIndex - content.textBlockBeginIndex + atomIndex);
			}
			
			return content;
		}
		
		public static function getContentElements(line:TextLine):Vector.<ContentElement>
		{
			var dict:Dictionary = new Dictionary();
			var tlmrs:Vector.<TextLineMirrorRegion> = line.mirrorRegions;
			
			if(!tlmrs)
				return elements;
			
			var n:int = tlmrs.length;
			
			for(var i:int = 0; i < n; ++i)
			{
				dict[tlmrs[i].element] = true;
			}
			
			var elements:Vector.<ContentElement> = new <ContentElement>[];
			for(var element:* in dict)
			{
				elements.push(ContentElement(element));
			}
			
			return elements;
		}
	}
}