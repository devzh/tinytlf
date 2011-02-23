package org.tinytlf.operations
{
	import org.tinytlf.ITextEngine;

	public class CaretMoveOperation extends TextOperation
	{
		public function CaretMoveOperation(props:Object=null)
		{
			super(props);
		}
		
		public var caret:int;
		public var maxCaret:Number = NaN;
		
		private var start:int;
		
		override public function execute():void
		{
			start = engine.caretIndex;
			
			if(maxCaret == maxCaret)
				caret = Math.min(maxCaret, caret);
			
			engine.caretIndex = caret;
		}
		
		override public function backout():void
		{
			caret = engine.caretIndex;
			engine.caretIndex = start;
		}
	}
}