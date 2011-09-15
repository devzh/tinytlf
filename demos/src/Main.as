package
{
	import embeds.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.URLRequest;
	import flash.text.engine.*;
	import flash.utils.*;
	
	import org.swiftsuspenders.*;
	import org.tinytlf.*;
	import org.tinytlf.content.*;
	import org.tinytlf.html.*;
	import org.tinytlf.interaction.*;
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.sector.*;
	import org.tinytlf.util.*;
	
	[SWF(width = "452", height = "500")]
	public class Main extends Sprite
	{
		private var helvetica:Helvetica;
		private var helveticaBold:HelveticaBold;
		private var helveticaItalic:HelveticaItalic;
		private var helveticaBoldItalic:HelveticaBoldItalic;
		
		public function Main()
		{
			const injector:Injector = new TextEngineInjector(new TextEngine());
			
			const g:Graphics = graphics;
			g.beginFill(0xFFFFFF, 1);
			g.lineStyle(1, 0xCCCCCC);
			g.drawRect(1, 1, stage.stageWidth - 1, stage.stageHeight - 1);
			
			const css:CSS = injector.getInstance(CSS);
			css.inject(new CSSSource().toString());
			css.inject('*{font-name: Helvetica;}');
			css.inject('p{' +
						   'padding-top: 5px;' +
						   'padding-bottom: 5px;' +
						   'text-align: justify;' +
					   '}' +
					   'a {' +
						   'color: #0000CC;' +
					   '}' +
					   'a:hover {' +
						   'color: #FF0000;' +
					   '}' +
					   'a:active {' +
						   'color: #FFFF00;' +
					   '}' +
					   'a:visited {' +
						   'color: #00FF00;' +
					   '}');
			
			const source:String = new HTMLSource().toString();
			const html:XML = TagSoup.toXML(source);
			css.inject(html..style.text().toString());
			
			const body:XML = html.localName() == 'body' ? html : (html..body[0] || <body>{html}</body>);
			
			const emm:IEventMirrorMap = injector.getInstance(IEventMirrorMap);
			emm.mapFactory('a', AnchorMirror);
			
			const dom:IDOMNode = new DOMNode(body);
			injector.injectInto(dom);
			
			const tsfm:ITextSectorFactoryMap = injector.getInstance(ITextSectorFactoryMap);
			
			const panes:Array = injector.getInstance(Array, '<TextPane>');
			const pane:TextPane = panes[0];
			pane.width = 450;
			pane.height = 498;
			pane.textSectors = tsfm.instantiate(dom.name).create(dom);
			
			const containers:Array = injector.getInstance(Array, '<Sprite>');
			addChild(containers[0]);
			containers[0].y += 1;
			containers[0].x += 1;
			
			const obs:Observables = injector.getInstance(Observables);
			obs.mouseWheel(stage).subscribe(function(me:MouseEvent):void {
				engine.scrollPosition -= me.delta;
			});
			
			const engine:ITextEngine = injector.getInstance(ITextEngine);
			engine.invalidate();
		}
	}
}
