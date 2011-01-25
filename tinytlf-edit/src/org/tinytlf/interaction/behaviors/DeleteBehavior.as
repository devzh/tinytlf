package org.tinytlf.interaction.behaviors
{
	import flash.geom.Point;
	
	import org.tinytlf.interaction.operations.*;

	public class DeleteBehavior extends OperationFactoryBehavior
	{
		[Event("keyDown")]
		public function deleteChars():void
		{
			var op:CompositeOperation = new CompositeOperation();
			
			if(!validSelection)
				selection = new Point(caret, caret + 1);
			
			op.add(
				new TextRemoveOperation({start:selection.x, end:selection.y}),
				new CaretMoveOperation({caret: selection.x + 1}),
				new TextSelectionOperation({selection: null})
			);
			
			op.runAtEnd(new InvalidateEngineOperation());
			
			initAndExecute(push(op));
		}
	}
}