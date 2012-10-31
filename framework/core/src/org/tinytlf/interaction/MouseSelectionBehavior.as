package org.tinytlf.interaction
{
	import flash.display.Stage;
	import flash.events.*;
	import flash.geom.Point;
	import flash.text.engine.*;
	import flash.ui.*;
	
	import org.tinytlf.*;
	import org.tinytlf.layout.box.*;
	
	import raix.reactive.*;
	
	public class MouseSelectionBehavior extends EventBehavior
	{
		[Inject('layout')]
		public var llv:Virtualizer;
		
		[Inject('content')]
		public var cllv:Virtualizer;
		
		[PostConstruct]
		override public function initialize():void
		{
			super.initialize();
			
			enabled = true;
		}
		
		private var _enabled:Boolean = true;
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			if(value == enabled)
				return;
			
			_enabled = value;
			invalidate();
		}
		
		private var moveCancelable:ICancelable;
		private var rollOutCancelable:ICancelable;
		private var dragCancelable:ICancelable;
		
		override protected function subscribe():void
		{
			if(!enabled)
				return;
			
			if(!moveCancelable)
			{
				moveCancelable = obs.move.take(1).subscribe(function(me:MouseEvent):void {
					
					const previousCursor:String = Mouse.cursor;
					Mouse.cursor = MouseCursor.IBEAM;
					
					rollOutCancelable = obs.rollOut.subscribe(function(me:MouseEvent):void {
						Mouse.cursor = previousCursor;
						
						if(rollOutCancelable) rollOutCancelable.cancel();
						rollOutCancelable = null;
						
						if(moveCancelable) moveCancelable.cancel();
						moveCancelable = null;
						
						subscribe();
					});
				});
			}
			
			if(!dragCancelable)
			{
				dragCancelable = obs.drag.subscribe(onDrag);
			}
		}
		
		override protected function cancel():void
		{
			if(moveCancelable)
			{
				moveCancelable.cancel();
				moveCancelable = null;
			}
			
			if(rollOutCancelable)
			{
				rollOutCancelable.cancel();
				rollOutCancelable = null;
			}
			
			if(dragCancelable)
			{
				dragCancelable.cancel();
				dragCancelable = null;
			}
		}
		
		override protected function intersectionFilter(me:MouseEvent):Boolean
		{
			return true;
		}
		
		override protected function onRender(event:Event):void
		{
			engine.removeEventListener(Event.RENDER, onRender);
			invalidated = false;
			enabled ? subscribe() : cancel();
		}
		
		protected function onDrag(me:MouseEvent):void
		{
			return;
			
			const line:TextLine = me.target as TextLine;
			
			if(!line)
				return;
			
			var box:Box;
			
			const row:Array = llv.getItemAtPosition(engine.scroll + line.y - line.ascent);
			
			if(!row)
				return;
			
			if(row.every(function(r:Box, ... args):Boolean {
				if(r.children.indexOf(line) != -1)
					box = r;
				return box == null;
			}))
			{
				return;
			}
			
			const s:Point = engine.selection;
			
			const here:int = cllv.getStart(box) +
				line.textBlockBeginIndex +
				line.getAtomIndexAtPoint(me.stageX, me.stageY);
			
			engine.select(here, here + 1);
		}
	}
}
