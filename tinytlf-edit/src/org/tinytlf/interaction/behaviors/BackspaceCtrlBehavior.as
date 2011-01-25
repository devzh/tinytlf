package org.tinytlf.interaction.behaviors
{
	import org.tinytlf.interaction.operations.*;
	import org.tinytlf.model.ITLFNode;
	import org.tinytlf.util.TinytlfUtil;
	import org.tinytlf.util.fte.TextLineUtil;

	public class BackspaceCtrlBehavior extends OperationFactoryBehavior
	{
		public function BackspaceCtrlBehavior()
		{
			super();
		}
		
		[Event("keyDown")]
		public function backspace():void
		{
			var op:CompositeOperation = new CompositeOperation();
			
			//Translate to the local atom index.
			var atomIndex:int = TinytlfUtil.globalIndexToAtomIndex(engine, line, caret);
			
			//Get the previous word boundary
			var start:int = TextLineUtil.getAtomWordBoundary(line, atomIndex);
			
			op.add(
				new TextRemoveOperation({start:start, end: caret}),
				new CaretMoveOperation({caret: TinytlfUtil.atomIndexToGlobalIndex(engine, line, start)}),
				new TextSelectionOperation({selection: null})
			);
			
			op.runAtEnd(new InvalidateEngineOperation());
			
			initAndExecute(push(op));
		}
	}
}