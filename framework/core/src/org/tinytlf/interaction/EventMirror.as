package org.tinytlf.interaction
{
	import flash.events.*;
	import flash.geom.*;
	import flash.text.engine.*;
	import flash.ui.*;
	
	import org.tinytlf.*;
	import org.tinytlf.html.*;
	import org.tinytlf.util.*;
	
	public class EventMirror
	{
		[Inject]
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
		}
		
		protected function cancel():void
		{
		}
		
		protected function intersectionFilter(me:MouseEvent):Boolean
		{
			return ContentElementUtil.
				getMirrorRegions(dom.content).
				some(function(tlmr:TextLineMirrorRegion, ... args):Boolean {
					const line:TextLine = tlmr.textLine;
					
					if(line.validity != TextLineValidity.VALID)
						return false;
					
					const bounds:Rectangle = new Rectangle();
					bounds.topLeft = line.localToGlobal(new Point(0, -line.ascent));
					bounds.bottomRight = line.localToGlobal(new Point(line.width, line.totalHeight - line.ascent));
					
					if(!bounds.contains(me.stageX, me.stageY))
						return false;
					
					const tlmrBounds:Rectangle = tlmr.bounds.clone();
					tlmrBounds.y += line.ascent;
					tlmrBounds.offset(bounds.x, bounds.y);
					return tlmrBounds.contains(me.stageX, me.stageY);
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
			invalidated = false;
			
			if(ContentElementUtil.getTextLines(dom.content).length > 0)
			{
				subscribe();
			}
			else
			{
				cancel();
			}
		}
	}
}
