package org.tinytlf.decor.selection
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	
	import org.tinytlf.analytics.ITextEngineAnalytics;
	import org.tinytlf.decor.TextDecor;
	import org.tinytlf.decor.TextDecoration;
	import org.tinytlf.layout.ITextContainer;
	
	public class SelectionDecorationBase extends TextDecoration
	{
		public function SelectionDecorationBase(styleObject:Object = null)
		{
			super(styleObject);
		}
		
		override public function setup(layer:int = 2, ... parameters):Vector.<Rectangle>
		{
			// We need to resolve some rects from our selection indicies.
			// Use the selection from the ITextEngine, don't force someone to 
			// pass them in as an argument. I suppose this violates 
			// encapsulation, but meh.
			var rects:Vector.<Rectangle> = new <Rectangle>[];
			var pt:Point = engine.selection.clone();
			var a:ITextEngineAnalytics = engine.analytics;
			var block:TextBlock;
			var index:int = 0;
			
			var indicies:Point;
			var start:Number = pt.x;
			
			while(start < pt.y)
			{
				index = a.indexAtContent(start);
				
				if(index == -1)
					break;
				
				block = a.blockAtIndex(index);
				
				if(block)
				{
					indicies = getBlockSelectionIndicies(block, pt.clone());
					
					if(indicies.x == indicies.x && indicies.y == indicies.y)
					{
						rects = rects.concat(getBlockRects(block, indicies));
					}
					else
					{
						break;
					}
				}
				
				start = a.indexContentStart(index) + a.indexContentSize(index);
			}
			
			return rects;
		}
		
		private function getBlockSelectionIndicies(block:TextBlock, selection:Point):Point
		{
			var a:ITextEngineAnalytics = engine.analytics;
			var start:Number = a.blockContentStart(block);
			var size:Number = a.blockContentSize(block);
			var end:Number = start + size;
			
			var p:Point = new Point();
			
			if(selection.y < start || selection.x > end)
			{
				p.x = p.y = NaN;
			}
			else
			{
				if(selection.x <= start)
					p.x = 0;
				else if(selection.x <= end)
					p.x = selection.x - start;
				
				if(selection.y > end)
					p.y = end;
				else if(selection.y <= end)
					p.y = selection.y - start;
				
				if(selection.x > end)
					p.x = p.y = NaN;
			}
			
			return p;
		}
		
		private function getBlockRects(block:TextBlock, selectionIndicies:Point):Vector.<Rectangle>
		{
			var a:ITextEngineAnalytics = engine.analytics;
			var blockSize:Number = a.blockContentSize(block);
			
			if(selectionIndicies.x == 0 && selectionIndicies.y >= blockSize - 1)
			{
				return super.setup(TextDecor.SELECTION_LAYER, block);
			}
			
			var rects:Vector.<Rectangle> = new <Rectangle>[];
			var line:TextLine = block.getTextLineAtCharIndex(selectionIndicies.x);
			var indicies:Point;
			
			while(line)
			{
				indicies = getLineSelectionIndicies(line, selectionIndicies);
				if(indicies.x == indicies.x && indicies.y == indicies.y)
				{
					rects.push(getLineRect(line, indicies));
					line = line.nextLine;
				}
				else
				{
					break;
				}
			}
			
			return rects;
		}
		
		private function getLineSelectionIndicies(line:TextLine, selection:Point):Point
		{
			var p:Point = new Point();
			var begin:int = line.textBlockBeginIndex;
			var end:int = begin + line.atomCount - 1;
			
			if(selection.y < begin || selection.x > end)
			{
				p.x = p.y = NaN;
			}
			else
			{
				if(selection.x <= begin)
					p.x = 0;
				else if(selection.x > begin)
					p.x = selection.x - begin;
				
				if(selection.y > end)
					p.y = end;
				else if(selection.y <= end)
					p.y = selection.y - begin;
			}
			
			return p;
		}
		
		private function getLineRect(line:TextLine, selectionIndicies:Point):Rectangle
		{
			var startIndex:int = selectionIndicies.x;
			var endIndex:int = selectionIndicies.y;
			
			if(startIndex >= line.atomCount)
				startIndex = line.atomCount - 1;
			if(endIndex >= line.atomCount)
				endIndex = line.atomCount - 1;
			
			var rect:Rectangle = line.getAtomBounds(startIndex);
			rect.width ||= 1;
			rect.height ||= 1;
			
			var rect2:Rectangle = line.getAtomBounds(endIndex);
			rect2.width ||= 1;
			rect2.height ||= 1;
			
			rect = rect.union(rect2);
			
			rect.offset(line.x, line.y);
			
			var container:ITextContainer = engine.layout.getContainerForLine(line);
			rectToContainer[rect] = ensureLayerExists(container, TextDecor.SELECTION_LAYER);
			
			return rect;
		}
	}
}