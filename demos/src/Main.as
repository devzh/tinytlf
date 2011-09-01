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
			
			injector.injectInto(pane);
			
			pane.width = 400;
			pane.height = 500;
			pane.textSectors = tsfm.instantiate(dom.name).create(dom);
			
			render();
		}
		
		private const injector:Injector = new TextEngineInjector(new TextEngine());
		private const pane:SectorPane = new SectorPane();
		
		private var container:Sprite;
		
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
			pane.scrollPosition = scrollPosition;
			render();
		}
		
		private function render():void
		{
			pane.render().
				forEach(function(line:TextLine, ... args):void {
					container.addChild(line);
				});
			
			totalHeight = pane.textHeight;
			container.scrollRect = new Rectangle(0, scrollPosition, 400, 500);
		}
	}
}
