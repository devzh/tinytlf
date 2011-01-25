package org.tinytlf.interaction.operations
{
	import org.tinytlf.ITextEngine;

	public class CaretMoveOperation extends TextOperation
	{
		public function CaretMoveOperation(props:Object=null)
		{
			super(props);
		}
		
		public var caret:int;
		public var maxCaret:int = NaN;
		
		private var start:int;
		
		override public function execute():void
		{
			start = engine.caretIndex;
			
			if(maxCaret == maxCaret)
				caret = Math.max(maxCaret, caret);
			
			engine.caretIndex = caret;
		}
		
		override public function backout():void
		{
			caret = engine.caretIndex;
			engine.caretIndex = start;
		}
	}
}