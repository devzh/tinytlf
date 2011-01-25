package org.tinytlf.interaction.operations
{
	import org.tinytlf.model.ITLFNode;

	public class TextRemoveOperation extends TextOperation implements ITextOperation
	{
		public function TextRemoveOperation(props:Object)
		{
			super(props);
		}
		
		public var start:int;
		public var end:int;
		private var value:ITLFNode;
		
		override public function execute():void
		{
			value = model.clone(start, end);
			model.remove(start, end)
		}
		
		override public function backout():void
		{
			model.insert(value.text, start);
		}
	}
}