package org.tinytlf.interaction
{
	import flash.events.*;
	import flash.geom.*;
	import flash.text.engine.*;
	import flash.ui.*;
	
	import org.tinytlf.*;
	import org.tinytlf.html.*;
	import org.tinytlf.util.*;
	
	public class EventBehavior
	{
		public var dom:IDOMNode;
		
		[Inject]
		public var obs:Observables;
		
		[Inject]
		public var engine:ITextEngine;
		
		[PostConstruct]
		public function initialize():void
		{
			engine.addEventListener(Event.RENDER, onRender);
		}
		
		protected function subscribe():void
		{
			cachedMirrorRects.length = 0;
			cachedMirrorRects.push.apply(
				cachedMirrorRects,
				
				ContentElementUtil.
					getMirrorRegions(dom.content).
					filter(function(tlmr:TextLineMirrorRegion, ...args):Boolean {
						return tlmr.textLine.validity == TextLineValidity.VALID;
					}).
					map(function(tlmr:TextLineMirrorRegion, ...args):Rectangle {
						const line:TextLine = tlmr.textLine;
						
						const bounds:Rectangle = new Rectangle();
						bounds.topLeft = line.localToGlobal(new Point(0, -line.ascent));
						bounds.bottomRight = line.localToGlobal(new Point(line.width, line.totalHeight - line.ascent));
						
						const tlmrBounds:Rectangle = tlmr.bounds.clone();
						tlmrBounds.y += line.ascent;
						tlmrBounds.offset(bounds.x, bounds.y);
						return tlmrBounds;
					})
			);
		}
		
		protected function cancel():void
		{
			cachedMirrorRects.length = 0;
		}
		
		protected const cachedMirrorRects:Array = [];
		
		protected function intersectionFilter(me:MouseEvent):Boolean
		{
			return cachedMirrorRects.some(function(rect:Rectangle, ... args):Boolean {
				return rect.contains(me.stageX, me.stageY);
			});
		}
		
		protected var invalidated:Boolean = false;
		protected function invalidate():void
		{
			cancel();
			
			if(invalidated)
				return;
			
			invalidated = true;
			engine.invalidate();
			engine.addEventListener(Event.RENDER, onRender);
		}
		
		protected function onRender(event:Event):void
		{
			engine.removeEventListener(Event.RENDER, onRender);
			
			if(ContentElementUtil.getTextLines(dom.content).length > 0)
				subscribe();
			else
				cancel();
			
			invalidated = false;
		}
	}
}
