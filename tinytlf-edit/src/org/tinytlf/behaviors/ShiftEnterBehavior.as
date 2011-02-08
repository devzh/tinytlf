package org.tinytlf.behaviors
{
	import flash.text.engine.TextBlock;
	
	import org.tinytlf.operations.*;
	import org.tinytlf.model.*;

	public class ShiftEnterBehavior extends OperationFactoryBehavior
	{
		[Event("keyDown")]
		public function down():void
		{
			var op:CompositeOperation = new CompositeOperation();
			
			if(validSelection)
			{
				op.add(
					new TextRemoveOperation({start: selection.x, end: selection.y}),
					new CaretMoveOperation({caret: selection.x + 1}),
					new TextSelectionOperation({selection: null})
				);
			}
			
			var index:int = ITLFNodeParent(model).getChildIndexAtPosition(caret);
			
			op.add(new SplitParagraphOperation({caret: caret, nodeIndex: index}));
			op.runAtEnd(new InvalidateEngineOperation());
			
			initAndExecute(push(op));
		}
	}
}