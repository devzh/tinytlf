package org.tinytlf.behaviors
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import org.tinytlf.operations.*;
	
	public class TextInsertBehavior extends OperationFactoryBehavior
	{
		[Event("keyDown")]
		public function insert(events:Vector.<Event>):void
		{
			var maxCaret:Number = NaN;
			var evt:KeyboardEvent = finalEvent as KeyboardEvent;
			var chars:String = String.fromCharCode(evt.charCode);
			
			var op:CompositeOperation = new CompositeOperation();
			
			if(validSelection)
			{
				op.add(new TextRemoveOperation({start:selection.x, end:selection.y}));
				
				if(caret == selection.y)
					caret -= (selection.y - selection.x);
				
				maxCaret = model.length - (selection.y - selection.x);
			}
			
			op.add(
				new TextInsertOperation({start:caret, value:chars, end:caret + 1}),
				new CaretMoveOperation({caret: ++caret, maxCaret: maxCaret}),
				new TextSelectionOperation({selection: null})
			);
			
			op.runAtEnd(new InvalidateEngineOperation());
			
			initAndExecute(push(op));
		}
	}
}