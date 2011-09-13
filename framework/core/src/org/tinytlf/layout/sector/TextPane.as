package org.tinytlf.layout.sector
{
	import flash.display.*;
	import flash.geom.*;
	import flash.text.engine.*;
	
	import org.tinytlf.*;
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.progression.*;
	import org.tinytlf.util.TextLineUtil;
	
	public class TextPane extends TextRectangle
	{
		[Inject("layout")]
		public var llv:Virtualizer;
		
		private const sectors:Array = [];
		private const unrenderedSectors:Array = [];
		
		public function set textSectors(value:Array):void
		{
			sectors.length = 0;
			sectors.push.apply(null, value);
			unrenderedSectors.length = 0;
			unrenderedSectors.push.apply(null, value);
			invalidate();
		}
		
		public function get leftoverSectors():Array /*<TextSector>*/
		{
			return unrenderedSectors.concat();
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
			
			for(var i:int = 0, n:int = 1; i < n; ++i)
			{
				const row:SectorRow = llv.getItemAtIndex(startIndex + i) || llv.add(new SectorRow(), 1);
				usedSpace += llv.getSize(llv.setSize(row, renderRow(row, llv.getStart(row))));
				
				// If we've filled all the space, stop rendering.
				if(startIndex < llv.length && usedSpace > (availableSpace + scrollDifference))
					break;
				
				// If there's still more space, go round one more time.
				if(usedSpace < (availableSpace + scrollDifference))
					++n;
				
				if(n >= sectors.length)
					break;
			}
			
			removeRowRange(n + startIndex, llv.length);
			
			setTotalSize(unrenderedSectors.length == 0 ? llv.size - availableSpace : getTotalSize() + usedSpace);
			
			invalidated = false;
			
			return children;
		}
		
		protected function renderRow(row:SectorRow, rowStart:Number):Number
		{
			var rowSize:Number = 0;
			row.forEach(function(sector:TextSector, ... args):void {
				setSectorStart(sector, rowStart);
				sector.render();
				kids.push.apply(null, sector.children);
				rowSize += aligner.getSize(sector);
			});
			
			const size:Number = getLayoutSize();
			
			while(rowSize < size)
			{
				const sector:TextSector = unrenderedSectors.shift();
				if(!sector)
					break;
				
				setSectorStart(sector, rowStart);
				setSectorSize(sector, size);
				
				kids.push.apply(null, sector.render());
				
				rowSize += getSectorSize(sector);
				row.push(sector);
			}
			
			return row.size;
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
				
				row.forEach(function(sector:TextSector, ... args):void {
					sector.children.forEach(function(line:TextLine, ... args):void {
						if(line.parent) line.parent.removeChild(line);
					});
//					sector.dispose();
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
		
		protected function getSectorSize(sector:TextSector):Number
		{
			return (blockProgression == TextBlockProgression.BTT ||
				blockProgression == TextBlockProgression.TTB) ?
				sector.width + sector.paddingLeft + sector.paddingRight :
				sector.height + sector.paddingTop + sector.paddingBottom;
		}
		
		protected function setSectorStart(sector:TextSector, start:Number):void
		{
			const prop:String =
				(blockProgression == TextBlockProgression.BTT ||
				blockProgression == TextBlockProgression.TTB) ?
				'y' : 'x';
			sector[prop] = start;
		}
		
		protected function setSectorSize(sector:TextSector, totalSize:Number):void
		{
			const prop:String = (blockProgression == TextBlockProgression.BTT ||
				blockProgression == TextBlockProgression.TTB) ?
				'width' : 'height';
			
			const percent:String = (prop == 'width') ? 'percentWidth' : 'percentHeight';
			
			if(sector[percent] == sector[percent])
				sector[prop] = sector[percent] * totalSize * .01;
			
			if(sector[prop] == 0)
				sector[prop] = totalSize;
		}
	}
}
