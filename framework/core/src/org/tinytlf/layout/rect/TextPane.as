package org.tinytlf.layout.rect
{
	import flash.display.*;
	import flash.geom.*;
	import flash.text.engine.*;
	import flash.utils.*;
	
	import org.swiftsuspenders.*;
	import org.tinytlf.*;
	import org.tinytlf.html.*;
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.progression.*;
	
	public class TextPane extends TextRectangle
	{
		[Inject('layout')]
		public var llv:Virtualizer;
		
		[Inject('content')]
		public var cllv:Virtualizer;
		
		override public function dispose():void
		{
			super.dispose();
			rects.length = 0;
		}
		
		private const rects:Array = [];
		
		public function set allTextRectangles(value:Array):void
		{
			rects.forEach(function(rect:TextRectangle, ... args):void {
				rect.dispose();
			});
			tw = 0;
			th = 0;
			
			rects.length = 0;
			rects.push.apply(null, value);
			
			invalidate();
		}
		
		private var scrollP:Number = 0;
		public function get scrollPosition():Number
		{
			return scrollP;
		}
		
		public function set scrollPosition(value:Number):void
		{
			if(value == scrollP)
				return;
			
			scrollP = value;
			invalidate();
		}
		
		private const sRect:Rectangle = new Rectangle();
		public function get scrollRect():Rectangle
		{
			sRect.width = width;
			sRect.height = height;
			
			const minProp:String = blockProgression == TextBlockProgression.TTB ? 'x' : 'y';
			const majProp:String = blockProgression == TextBlockProgression.TTB ? 'y' : 'x';
			const multiplier:int = blockProgression == TextBlockProgression.TTB ||
				blockProgression == TextBlockProgression.LTR ? 1 : -1;
			
			sRect[minProp] = 0;
			sRect[majProp] = scrollP * multiplier;
			return sRect;
		}
		
		private var topIndexCache:int = 0;
		
		override public function render():Array
		{
			if(rects.length <= 0)
				return children;
			
			const unique:Dictionary = new Dictionary(false);
			kids.filter(function(kid:DisplayObject, i:int, ... args):Boolean {
				return (kid in unique) ? false : (unique[kid] = (kid.parent != null));
			}).
			forEach(function(kid:DisplayObject, ... args):void {
				kid.parent.removeChild(kid);
			});
			kids.length = 0;
			
			const rowIndex:int = llv.getIndexAt(scrollP) > -1 ?
				llv.getIndexAt(scrollP) :
				Math.max(llv.length - 1, 0);
			
			removeRowRange(topIndexCache, topIndexCache = rowIndex);
			
			const availableSpace:Number = getProgressionSize();
			const scrollDifference:Number = scrollP - llv.getStart(llv.getItemAtIndex(rowIndex));
			
			var usedSpace:Number = 0;
			var rectIndex:int = -1;
			var i:int = rowIndex, n:int = rowIndex + 1;
			
			for(; i < n; ++i)
			{
				const row:TextPaneRow = llv.getItemAtIndex(i) || llv.add(new TextPaneRow(), 1);
				
				if(rectIndex == -1)
					rectIndex = row.startRectangleIndex;
				else
					row.startRectangleIndex = rectIndex;
				
				const temp:Array = rects.concat();
				rects.length = 0;
				rects.push.apply(null, parseRowRectangles(row, llv.getStart(row), rectIndex, temp));
				
				row.forEach(function(rect:TextRectangle, ...args):void {
					kids.push.apply(null, rect.render());
				});
				
				rectIndex += row.length;
				
				usedSpace += llv.getSize(llv.setSize(row, row.progressionSize));
				
				// If we've filled all the space, stop rendering.
				if(usedSpace > (availableSpace + scrollDifference))
					break;
				
				if(n >= (rects.length))
					break;
				
				// If there's still space, go another time around.
				++n;
			}
			
			removeRowRange(n, llv.length);
			
			setTotalSize(n >= rects.length ? getTotalSize() : availableSpace + usedSpace);
			
			invalid = false;
			
			return children;
		}
		
		protected function parseRowRectangles(row:TextPaneRow,
											  start:Number,
											  index:int,
											  allRectangles:Array):Array /*<TextRectangle>*/
		{
			row.length = 0;
			row.progression = blockProgression;
			
			const totalSpace:Number = getLayoutSize();
			while(row.layoutSize < totalSpace)
			{
				const rect:TextRectangle = allRectangles[index];
				if(!rect)
					break;
				
				rect.blockProgression = blockProgression;
				rect.progression = progression;
				
				setRectStart(rect, start);
				
				setRectSize(rect, Math.min(totalSpace, totalSpace - row.layoutSize));
				
				row.pushRectangle(rect);
				
				if(rect.invalidated)
				{
					const cache:Array = rect.parsedRectangleCache;
					const firstInvalidRect:TextRectangle = cache[0];
					const lastInvalidRect:TextRectangle = cache[cache.length - 1];
					if(cache.length > 1 && firstInvalidRect && lastInvalidRect)
					{
						const firstIndex:int = allRectangles.indexOf(firstInvalidRect);
						const lastIndex:int = allRectangles.indexOf(lastInvalidRect);
						if(firstIndex != -1 && lastIndex != -1)
						{
							allRectangles.splice(firstIndex + 1, lastIndex - firstIndex + 1);
						}
					}
					
					const parsed:Array = rect.parse();
					allRectangles.splice.apply(null, [index + 1, 0].concat(parsed.slice(1)));
				}
				
				++index;
			}
			
			return allRectangles;
		}
		
		protected function removeRowRange(startIndex:int, endIndex:int):void
		{
			if(endIndex < startIndex)
			{
				const s:int = startIndex;
				startIndex = endIndex;
				endIndex = s;
			}
			
			for(var i:int = startIndex, n:int = endIndex; i < n; ++i)
			{
				const row:TextPaneRow = llv.getItemAtIndex(i);
				
				if(!row)
					continue;
				
				row.forEach(function(rect:TextRectangle, ... args):void {
					rect.dispose();
				});
			}
		}
		
		/*
		 * I could write a block progression implementation for these methods,
		 * but it's cheaper on SWC size if I keep them here.
		 */
		
		protected function getProgressionSize():Number
		{
			return blockProgression == TextBlockProgression.TTB ? height : width;
		}
		
		protected function getLayoutSize():Number
		{
			return blockProgression == TextBlockProgression.TTB ? width : height;
		}
		
		protected function setTotalSize(size:Number):void
		{
			const prop:String = blockProgression == TextBlockProgression.TTB ? 'th' : 'tw';
			this[prop] = size;
		}
		
		protected function getTotalSize():Number
		{
			return blockProgression == TextBlockProgression.TTB ? textHeight : textWidth;
		}
		
		protected function setRectStart(rect:TextRectangle, start:Number):void
		{
			const prop:String = blockProgression == TextBlockProgression.TTB ? 'y' : 'x';
			
			if(blockProgression == TextBlockProgression.RTL)
				start = getProgressionSize() - start;
			
			rect[prop] = start;
		}
		
		protected function getRectStart(rect:TextRectangle):Number
		{
			const prop:String = blockProgression == TextBlockProgression.TTB ? 'y' : 'x';
			return rect[prop];
		}
		
		protected function setRectSize(rect:TextRectangle, totalSize:Number):void
		{
			const prop:String = blockProgression == TextBlockProgression.TTB ? 'width' : 'height';
			const percent:String = (prop == 'width') ? 'percentWidth' : 'percentHeight';
			
			if(!rect[prop] && rect[percent] == rect[percent])
			{
				totalSize = rect[percent] * totalSize * .01;
			}
			else
			{
				totalSize = Math.min(rect[prop], totalSize);
			}
			
			rect[prop] = totalSize;
		}
	
//		override public function getSelectionRects(start:int, end:int):Array
//		{
//			const rects:Array = [];
//			
//			var index:int = cllv.getIndexAt(start);
//			var textRect:TextRectangle = cllv.getItemAtIndex(index);
//			var rowIndex:int = llv.getIndexAt(textRect.y);
//			var row:TextPaneRow = llv.getItemAtPosition(rowIndex);
//			
//			while(true)
//			{
//				row.forEach(function(rect:TextRectangle, ... args):void {
//					if(cllv.getEnd(rect) < start)
//						return;
//					const localStart:int = Math.max(start - cllv.getStart(rect), 0);
//					const localEnd:int = Math.min(end - cllv.getStart(rect), cllv.getSize(rect));
//					rects.push.apply(null, rect.getSelectionRects(localStart, localEnd));
//				});
//				
//				index += row.length;
//				textRect = cllv.getItemAtIndex(index);
//				row = llv.getItemAtIndex(++rowIndex);
//				
//				if(!row || !textRect || end <= cllv.getEnd(textRect))
//				{
//					break;
//				}
//			}
//			
//			return rects;
//		}
	}
}
