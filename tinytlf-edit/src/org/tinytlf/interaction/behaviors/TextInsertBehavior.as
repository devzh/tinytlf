package org.tinytlf.interaction.behaviors
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	
	import org.tinytlf.model.ITLFNode;

	public class TextInsertBehavior extends MultiGestureBehavior
	{
		public function TextInsertBehavior()
		{
			super();
		}
		
		[Event("keyDown")]
		public function insert(events:Vector.<Event>):void
		{
			var model:ITLFNode = engine.layout.textBlockFactory.data as ITLFNode;
			if(!model)
				return;
			
			var selection:Point = engine.selection.clone();
			var index:int = engine.caretIndex;
			
			if(selection.x == selection.x && selection.y == selection.y)
			{
				model.remove(selection.x, selection.y);
				if(index == selection.y)
					index -= (selection.y - selection.x);
			}
			
			index = Math.max(model.length, index);
			var evt:KeyboardEvent = events.pop() as KeyboardEvent;
			var char:String = String.fromCharCode(evt.charCode);
			model.insert(char, index);
			++index;
			
			engine.caretIndex = index;
			engine.select();
			engine.invalidate();
		}
	}
}