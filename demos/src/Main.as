package
{
	import embeds.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.engine.*;
	import flash.utils.*;
	
	import org.swiftsuspenders.*;
	import org.tinytlf.*;
	import org.tinytlf.content.*;
	import org.tinytlf.html.*;
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.sector.*;
	import org.tinytlf.util.*;
	import org.tinytlf.virtualization.*;
	
	[SWF(width = "402", height = "502")]
	public class Main extends Sprite
	{
		private var helvetica:Helvetica;
		private var helveticaBold:HelveticaBold;
		private var helveticaItalic:HelveticaItalic;
		private var helveticaBoldItalic:HelveticaBoldItalic;
		
		public function Main()
		{
			const g:Graphics = graphics;
			g.lineStyle(1, 0xCCCCCC);
			g.drawRect(1, 1, stage.stageWidth - 1, stage.stageHeight - 1);
			
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, onScroll);
			
			container = addChild(new Sprite()) as Sprite;
			
			const css:CSS = injector.getInstance(CSS);
			css.inject(new CSSSource().toString());
			css.inject('*{font-name: Helvetica;}');
			css.inject('p{' +
					   'padding-top: 10;' +
					   'padding-bottom: 0;' +
					   'text-align: justify;' +
					   '}');
			
			const html:XML = TagSoup.toXML(new HTMLSource().toString(), false);
			const dom:IDOMNode = new DOMNode(html);
			injector.injectInto(dom);
			
			const tsfm:ITextSectorFactoryMap = injector.getInstance(ITextSectorFactoryMap);
			tsfm.mapFactory('div', TSFactory);
			tsfm.mapFactory('ol', TSFactory);
			tsfm.mapFactory('body', TSFactory);
			tsfm.mapFactory('br', LineBreakTSF);
			tsfm.mapFactory('table', LineBreakTSF);
			
			sectors = tsfm.instantiate(dom.name).create(dom);
			
			render();
		}
		
		private const injector:Injector = new TextEngineInjector(new TextEngine());
		
		private var container:Sprite;
		private var sectors:Array = [];
		
		private const visibleRows:Point = new Point();
		
		private function render(start:Number = 0):void
		{
			const vir:IVirtualizer = injector.getInstance(IVirtualizer);
			const w:Number = stage.stageWidth - 2;
			const h:Number = 500;
			
			if(start < 0)
				start = 0;
			
			if(start > vir.size)
				start = vir.size;
			
			container.scrollRect = new Rectangle(0, start, w, h);
			
			var i:int = vir.getIndexAt(start);
			if(i == -1)
				i = vir.length;
			
			var n:int = vir.getIndexAt(Math.max(start + h - 1, 0));
			if(n == -1 || n == 1)
				n = i + Math.min(10, sectors.length);
			
			const startIndex:int = i;
			
			var renderedHeight:Number = 0;
			var row:SectorRow;
			
			checkEarlierRowsForInvalidation(i, visibleRows.x);
			checkLaterRowsForInvalidation(n, visibleRows.y);
			
			visibleRows.x = i;
			
			for(; i <= n; ++i)
			{
				row = vir.getItemAtIndex(i) || vir.add(new SectorRow(), 1);
				const y:Number = vir.getStart(row);
				
				var rowWidth:Number = 0;
				
				row.forEach(function(sector:TextSector, ... args):void {
					sector.y = y;
					
					sector.render();
					
					sector.
						textLines.
						forEach(function(line:TextLine, ... args):void {
							container.addChild(line);
						});
					
					rowWidth += sector.width + sector.paddingLeft + sector.paddingRight;
				});
				
				while(rowWidth < w)
				{
					const sector:TextSector = sectors.shift();
					if(!sector)
						break;
					
					sector.y = y;
					
					if(sector.percentWidth == sector.percentWidth)
						sector.width = sector.percentWidth * w * .01;
					if(sector.width == 0)
						sector.width = w;
					
					sector.
						render().
						forEach(function(line:TextLine, ... args):void {
							container.addChild(line);
						});
					
					rowWidth += sector.width + sector.paddingLeft + sector.paddingRight;
					row.push(sector);
				}
				
				vir.setSize(row, row.size);
				
				if(vir.getSize(row) == 0)
				{
					vir.remove(row);
				}
				
				renderedHeight += row.size;
				
				if(startIndex < vir.length)
				{
					const difference:Number = start - vir.getStart(vir.getItemAtIndex(startIndex));
					// If we've filled all the space, stop rendering.
					if(renderedHeight > (h + difference))
					{
						n -= (n - i);
						break;
					}
				}
				
				// If we haven't rendered lines to fill the space, keep rendering.
				if((i == n - 1) && renderedHeight < h)
				{
					n += Math.min(10, sectors.length);
				}
			}
			
			cleanUpEarlierRows(startIndex);
			cleanUpLaterRows(n);
			
			visibleRows.y = n;
			
			if(sectors.length == 0)
				totalHeight = vir.size - 500;
			else
				totalHeight += renderedHeight;
		}
		
		private function checkEarlierRowsForInvalidation(newIndex:int, currentIndex:int):void
		{
			if(newIndex >= currentIndex)
				return;
			
			const vir:IVirtualizer = injector.getInstance(IVirtualizer);
			
			for(var i:int = newIndex; i <= currentIndex; ++i)
			{
				const row:SectorRow = vir.getItemAtIndex(i);
				if(!row)
					continue;
				
				row.forEach(function(sector:TextSector, ... args):void {
					sector.invalidate();
				});
			}
		}
		
		private function checkLaterRowsForInvalidation(newIndex:int, currentIndex:int):void
		{
			if(newIndex <= currentIndex)
				return;
			
			const vir:IVirtualizer = injector.getInstance(IVirtualizer);
			
			for(var k:int = currentIndex; k < newIndex; ++k)
			{
				const row:SectorRow = vir.getItemAtIndex(k);
				if(!row)
					continue;
				
				row.forEach(function(sector:TextSector, ... args):void {
					sector.invalidate();
				});
			}
		}
		
		private function cleanUpEarlierRows(index:int):void
		{
			if(index <= visibleRows.x)
				return;
			
			const vir:IVirtualizer = injector.getInstance(IVirtualizer);
			
			for(var i:int = visibleRows.x; i < index; ++i)
			{
				const row:SectorRow = vir.getItemAtIndex(i);
				if(!row)
					continue;
				
				row.forEach(function(sector:TextSector, ... args):void {
					sector.
						textLines.
						forEach(function(line:TextLine, ... args):void {
							if(line.parent == container)
								container.removeChild(line);
						});
				});
			}
		}
		
		private function cleanUpLaterRows(index:int):void
		{
			if(index >= visibleRows.y)
				return;
			
			const vir:IVirtualizer = injector.getInstance(IVirtualizer);
			
			for(var i:int = index + 1; i < visibleRows.y; ++i)
			{
				const row:SectorRow = vir.getItemAtIndex(i);
				if(!row)
					continue;
				
				row.forEach(function(sector:TextSector, ... args):void {
					sector.
						textLines.
						forEach(function(line:TextLine, ... args):void {
							if(line.parent == container)
								container.removeChild(line);
						});
				});
			}
		}
		
		private var scrollPosition:Number = 0;
		private var totalHeight:Number = 500;
		
		private function onScroll(event:MouseEvent):void
		{
			if(scrollPosition != Math.min(Math.max(scrollPosition - event.delta, 0), totalHeight))
			{
				scrollPosition = Math.min(Math.max(scrollPosition - event.delta, 0), totalHeight);
				stage.invalidate();
				stage.addEventListener(Event.RENDER, onRender);
			}
		}
		
		private function onRender(... args):void
		{
			stage.removeEventListener(Event.RENDER, onRender);
			render(scrollPosition);
		}
	}
}
