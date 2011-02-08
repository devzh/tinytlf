package org.tinytlf.behaviors
{
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import org.tinytlf.util.TinytlfUtil;
	import org.tinytlf.util.fte.TextLineUtil;
	
	public class MouseSelectionBehavior extends SelectionBehaviorBase
	{
		public function MouseSelectionBehavior()
		{
			super();
		}
		
		protected var triggeredHere:Boolean = false;
		
		[Event("mouseDown")]
		override public function downAction():void
		{
			super.downAction();
			
			engine.select();
			
			triggeredHere = true;
		}
		
		[Event("mouseMove")]
		override public function moveAction():void
		{
			var m:MouseEvent = MouseEvent(finalEvent);
			if(!m.buttonDown || !triggeredHere)
				return;
			
			super.moveAction();
		}
		
		[Event("mouseUp")]
		override public function upAction():void
		{
			super.upAction();
			triggeredHere = false;
		}
		
		override protected function getAnchor():Point
		{
			var m:MouseEvent = MouseEvent(finalEvent);
			var atomIndex:int = TextLineUtil.getAtomIndexAtPoint(line, new Point(m.stageX, m.stageY));
			var globalIndex:int = TinytlfUtil.atomIndexToGlobalIndex(engine, line, atomIndex);
			return new Point(globalIndex, globalIndex);
		}
		
		override protected function getSelection():Point
		{
			return getAnchor();
		}
	}
}