package org.tinytlf.components
{
	import flash.display.*;
	import flash.events.*;
	
	import org.swiftsuspenders.*;
	import org.tinytlf.*;
	import org.tinytlf.html.*;
	import org.tinytlf.interaction.*;
	import org.tinytlf.layout.*;
	import org.tinytlf.layout.rect.*;
	import org.tinytlf.util.*;
	
	public class TextField extends ComponentBase
	{
		public function TextField()
		{
			super();
			
			injector = new TextEngineInjector(new TextEngine());
		}
		
		private var _css:String = '';
		private var proposedCSS:String = '';
		public function get css():String
		{
			return _css;
		}
		
		public function set css(value:String):void
		{
			if(value == _css)
				return;
			
			proposedCSS = value;
			invalidate();
		}
		
		private var _html:XML = <_/>;
		private var proposedHTML:* = '';
		
		public function get html():*
		{
			return _html;
		}
		
		public function set html(value:*):void
		{
			if(!(value is XML || value is String))
			{
				throw new ArgumentError('HTML must be either XML or a String.');
			}
			
			proposedHTML = value;
			invalidate();
		}
		
		private var _injector:Injector;
		private var injectorChanged:Boolean = false;
		
		public function get injector():Injector
		{
			return _injector;
		}
		
		public function set injector(value:Injector):void
		{
			if(value == injector || !value)
				return;
			
			_injector = value;
			injectorChanged = true;
			invalidate();
		}
		
		private var invalidated:Boolean = false;
		public function invalidate():void
		{
			if(invalidated)
				return;
			
			invalidated = true;
			addEventListener(Event.ENTER_FRAME, function(e:Event):void {
				removeEventListener(e.type, arguments.callee);
				validate();
				invalidated = false;
			});
		}
		
		protected function validate():void
		{
			if(injectorChanged || proposedCSS || proposedHTML)
			{
				const engine:ITextEngine = injector.getInstance(ITextEngine);
				const c:CSS = injector.getInstance(CSS);
				
				const llv:Virtualizer = injector.getInstance(Virtualizer, 'layout');
				llv.clear();
				
				if(injectorChanged)
				{
					while(numChildren)
					{
						removeChildAt(0);
					}
					
					const obs:Observables = injector.getInstance(Observables);
					obs.mouseWheel(this).subscribe(function(me:MouseEvent):void {
						engine.scrollPosition -= me.delta;
					});
					injectorChanged = false;
				}
				if(proposedCSS)
				{
					_css = proposedCSS;
					c.clearStyles();
					c.inject(css);
					engine.scrollPosition = 0;
					proposedCSS = '';
				}
				if(proposedHTML)
				{
					const cllv:Virtualizer = injector.getInstance(Virtualizer, 'content');
					cllv.clear();
					
					if(proposedHTML is String)
					{
						proposedHTML = TagSoup.toXML(proposedHTML);
					}
					
					_html = createHTML_XML(proposedHTML as XML);
					c.inject(html..style.text().toString());
					engine.scrollPosition = 0;
					proposedHTML = null;
				}
				
				const g:Graphics = graphics;
				g.clear();
				g.beginFill(0xFFFFFF, 1);
				g.lineStyle(1, 0xCCCCCC);
				g.drawRect(1, 1, width - 1, height - 1);
				
				const dom:IDOMNode = new DOMNode(html);
				injector.injectInto(dom);
				
				const panes:Array = injector.getInstance(Array, '<TextPane>');
				const pane:TextPane = panes[0];
				pane.blockProgression = TextBlockProgression.convert(dom.getStyle('textDirection') || TextBlockProgression.TTB);
				pane.width = width - 2;
				pane.height = height - 2;
				pane.allTextRectangles = createTextRectangles(dom);
				
				const containers:Array = injector.getInstance(Array, '<Sprite>');
				addChild(containers[0]);
				containers[0].x = 1;
				containers[0].y = 2;
				
				engine.invalidate();
			}
		}
		
		protected function createHTML_XML(from:XML):XML
		{
			return from.localName() == 'body' ?
				from :
				(from..body[0] || <body>{from}</body>)
		}
		
		protected function createTextRectangles(root:IDOMNode):Array /*<TextRectangle>*/
		{
			return injector.
				getInstance(ITextRectangleFactoryMap).
				instantiate(root.nodeName).
				create(root);
		}
	}
}
