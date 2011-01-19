package org.tinytlf.interaction.behaviors
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
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
			
			var evt:KeyboardEvent = events.pop() as KeyboardEvent;
			var index:int = engine.caretIndex;
			var char:String = String.fromCharCode(evt.charCode);
			model.insert(char, index);
			++engine.caretIndex;
			engine.invalidate();
		}
	}
}