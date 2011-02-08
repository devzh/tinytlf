package org.tinytlf.behaviors
{
	import flash.geom.Point;
	
	import org.tinytlf.operations.*;
	import org.tinytlf.model.ITLFNode;

	public class BackspaceBehavior extends OperationFactoryBehavior
	{
		[Event("keyDown")]
		public function backspace():void
		{
			var op:CompositeOperation = new CompositeOperation();
			
			if(!validSelection)
				selection = new Point(--caret, caret + 1);
			else
				caret = selection.x;
			
			op.add(
				new TextRemoveOperation({start:selection.x, end:selection.y}),
				new CaretMoveOperation({caret: caret}),
				new TextSelectionOperation({selection: null})
			);
			
			op.runAtEnd(new InvalidateEngineOperation());
			
			initAndExecute(push(op));
		}
	}
}