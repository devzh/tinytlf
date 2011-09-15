package org.tinytlf.layout.sector
{
	import flash.display.*;
	import flash.geom.*;
	import flash.text.engine.*;
	
	import org.swiftsuspenders.*;
	import org.tinytlf.*;
	import org.tinytlf.html.*;
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.progression.*;
	
	public class TextPane extends TextRectangle
	{
		[Inject("layout")]
		public var llv:Virtualizer;
		
		override public function dispose():void
		{
			super.dispose();
			masterSectorList.length = 0;
			unparsedSectorsList.length = 0;
			parsedSectorsList.length = 0;
		}
		
		private const masterSectorList:Array = [];
		private const parsedSectorsList:Array = [];
		private const unparsedSectorsList:Array = [];
		
		public function set textSectors(value:Array):void
		{
			masterSectorList.length = 0;
			masterSectorList.push.apply(null, value);
			parsedSectorsList.length = 0;
			unparsedSectorsList.length = 0;
			unparsedSectorsList.push.apply(null, value);
			invalidate();
		}
		
		public function get leftoverSectors():Array /*<TextSector>*/
		{
			return unparsedSectorsList.concat();
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
		
		private var firstIndexCache:int = 0;
		private var lastIndexCache:int = 0;
		
		override public function render():Array
		{
			kids.length = 0;
			
			var startIndex:int = llv.getIndexAt(scrollP);
			if(startIndex == -1)
				startIndex = Math.max(llv.length - 1, 0);
			
			removeRowRange(firstIndexCache, firstIndexCache = startIndex);
			
			const availableSpace:Number = getProgressionSize();
			const scrollDifference:Number = scrollP - llv.getStart(llv.getItemAtIndex(startIndex));
			
			var usedSpace:Number = 0;
			
			for(var i:int = startIndex, n:int = startIndex + 1; i < n; ++i)
			{
				const row:SectorRow = llv.getItemAtIndex(i) || llv.add(new SectorRow(), 1);
				usedSpace += llv.getSize(llv.setSize(row, renderRow(row, llv.getStart(row))));
				
				// If we've filled all the space, stop rendering.
				if(startIndex < llv.length && usedSpace > (availableSpace + scrollDifference))
					break;
				
				// If there's still more space, go round one more time.
				if(usedSpace <= (availableSpace + scrollDifference))
					++n;
				
				if(n >= (parsedSectorsList.length + unparsedSectorsList.length))
					break;
			}
			
			removeRowRange(n, llv.length);
			
			setTotalSize(unparsedSectorsList.length == 0 ? llv.size - availableSpace : getTotalSize() + usedSpace);
			
			invalid = false;
			
			return children;
		}
		
		protected function renderRow(row:SectorRow, rowStart:Number):Number
		{
			if(row.length)
			{
				row.forEach(function(sector:TextRectangle, ... args):void {
					setSectorStart(sector, rowStart);
					sector.parse();
					kids.push.apply(null, sector.render());
				});
			}
			else
			{
				var rowSize:Number = 0;
				const size:Number = getLayoutSize();
				
				while(rowSize < size)
				{
					var sector:TextRectangle = unparsedSectorsList.shift();
					if(!sector)
						break;
					
					const index:int = parsedSectorsList.length;
					const parsedList:Array = sector.parse();
					unparsedSectorsList.unshift.apply(null, parsedList.slice(1));
					parsedSectorsList.push(sector);
					sector = parsedSectorsList[index];
					
					if(!sector)
						break;
					
					setSectorStart(sector, rowStart);
					setSectorSize(sector, Math.min(size, size - row.layoutSize));
					setSectorAlignment(sector);
					
					row.pushRectangle(sector);
					
					kids.push.apply(null, sector.render());
					
					rowSize += aligner.getSize(sector, sector);
				}
			}
			
			return row.progressionSize;
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
				const row:SectorRow = llv.getItemAtIndex(i);
				
				if(!row)
					continue;
				
				row.forEach(function(sector:TextRectangle, ... args):void {
					sector.dispose();
				});
			}
		}
		
		/*
		 * I could write a block progression implementation for these methods,
		 * but it's cheaper on SWC size if I keep them here.
		 */
		
		protected function getProgressionSize():Number
		{
			return (blockProgression == TextBlockProgression.BTT ||
				blockProgression == TextBlockProgression.TTB) ?
				height : width;
		}
		
		protected function getLayoutSize():Number
		{
			return (blockProgression == TextBlockProgression.BTT ||
				blockProgression == TextBlockProgression.TTB) ?
				width : height;
		}
		
		protected function setTotalSize(size:Number):void
		{
			const prop:String =
				(blockProgression == TextBlockProgression.BTT ||
				blockProgression == TextBlockProgression.TTB) ?
				'th' : 'tw';
			this[prop] = size;
		}
		
		protected function getTotalSize():Number
		{
			return (blockProgression == TextBlockProgression.BTT ||
				blockProgression == TextBlockProgression.TTB) ?
				textHeight : textWidth;
		}
		
		protected function setSectorStart(sector:TextRectangle, start:Number):void
		{
			const prop:String =
				(blockProgression == TextBlockProgression.BTT ||
				blockProgression == TextBlockProgression.TTB) ?
				'y' : 'x';
			sector[prop] = start;
		}
		
		protected function setSectorSize(sector:TextRectangle, totalSize:Number):void
		{
			const prop:String = (blockProgression == TextBlockProgression.BTT ||
				blockProgression == TextBlockProgression.TTB) ?
				'width' : 'height';
			
			const percent:String = (prop == 'width') ? 'percentWidth' : 'percentHeight';
			
			if(!sector[prop] && sector[percent] == sector[percent])
			{
				totalSize = sector[percent] * totalSize * .01;
			}
			else
			{
				totalSize = Math.min(sector[prop], totalSize);
			}
			
			sector[prop] = totalSize;
		}
		
		protected function setSectorAlignment(rect:TextRectangle):void
		{
			const prop:String =
				(blockProgression == TextBlockProgression.BTT ||
					blockProgression == TextBlockProgression.TTB) ?
				'x' : 'y';
			rect[prop] = aligner.getStart(rect, rect);
		}
	}
}
