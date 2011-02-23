package org.tinytlf.interaction
{
	import flash.events.MouseEvent;
	import flash.text.engine.ElementFormat;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import org.tinytlf.decor.ITextDecor;
	import org.tinytlf.model.ITLFNode;
	import org.tinytlf.util.TinytlfUtil;
	
	public class CSSMirror extends EventMirrorBase
	{
		public function CSSMirror()
		{
			super();
		}
		
		protected static const NORMAL:String = 'normal';
		protected static const ACTIVE:String = 'active';
		protected static const HOVER:String = 'hover';
		protected static const VISITED:String = 'visited';
		
		private var _cssState:String = NORMAL;
		protected function get cssState():String
		{
			return _cssState;
		}
		
		protected function set cssState(value:String):void
		{
			repealCSSProperties(cssState);
			
			_cssState = value;
			
			applyCSSProperties(cssState);
		}
		
		protected var visited:Boolean = false;
		
		[Event("mouseUp")]
		public function up():void
		{
			visited ||= cssState == ACTIVE;
			cssState = visited ? VISITED : NORMAL;
		}
		
		[Event("mouseDown")]
		public function down():void
		{
			cssState = ACTIVE;
		}
		
		[Event("mouseMove")]
		public function move():void
		{
			applyCSSProperties(cssState);
		}
		
		[Event("rollOver")]
		[Event("mouseOver")]
		public function over(event:MouseEvent):void
		{
			if(cssState == ACTIVE && event.buttonDown)
			{
				line.stage.removeEventListener(MouseEvent.MOUSE_UP, outUp, true);
				cssState = ACTIVE;
			}
			else
			{
				cssState = HOVER;
			}
		}
		
		[Event("rollOut")]
		[Event("mouseOut")]
		public function out(event:MouseEvent):void
		{
			if(cssState == ACTIVE && event.buttonDown)
			{
				line.stage.addEventListener(MouseEvent.MOUSE_UP, outUp, true);
				cssState = ACTIVE;
			}
			else
			{
				cssState = visited ? VISITED : NORMAL;
			}
		}
		
		protected function outUp(event:MouseEvent):void
		{
			event.currentTarget.removeEventListener(event.type, outUp, true);
			cssState = visited ? VISITED : NORMAL;
		}
		
		protected function applyCSSProperties(state:String):void
		{
			var props:Object = resolveCSSProperties(state);
			
			if(!props)
				return;
			
			applyFormat(props);
			engine.decor.decorate(content, props);
			Mouse.cursor = props['cursor'] || MouseCursor.AUTO;
		}
		
		protected function repealCSSProperties(state:String):void
		{
			var props:Object = resolveCSSProperties(state);
			if(!props)
				return;
			
			applyFormat(props);
			
			var decor:ITextDecor = engine.decor; 
			
			for(var prop:String in props)
				decor.undecorate(content, prop);
			
			Mouse.cursor = props['cursor'] || MouseCursor.AUTO;
		}
		
		protected function applyFormat(properties:Object):void
		{
			var format:ElementFormat = engine.styler.getElementFormat(properties);
			if(TinytlfUtil.compareObjectValues(content.elementFormat, format, {locked:true}) == false)
			{
				content.elementFormat = format;
				engine.invalidateLines();
			}
		}
		
		protected const stateCache:Object = {};
		
		protected function resolveCSSProperties(state:String):Object
		{
			if(state in stateCache)
				return stateCache[state];
			
			var node:ITLFNode = content.userData as ITLFNode;
			
			if(!node)
				return {};
			
			return stateCache[state] = node[state + ':'];
		}
	}
}