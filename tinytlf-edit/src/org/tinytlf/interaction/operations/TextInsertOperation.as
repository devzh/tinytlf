package org.tinytlf.interaction.operations
{
	import org.tinytlf.model.ITLFNode;
	
	public class TextInsertOperation extends TextOperation implements ITextOperation
	{
		public function TextInsertOperation(props:Object)
		{
			super(props);
		}
		
		public var start:int;
		public var end:int;
		public var value:String;
		
		override public function execute():void
		{
			model.insert(value, start);
		}
		
		override public function backout():void
		{
			model.remove(start, end);
		}
		
		override public function merge(op:ITextOperation):void
		{
			super.merge(op);
			
			var obj:TextInsertOperation = TextInsertOperation(op);
			if(obj.start < start)
			{
				value = obj.value + value;
				start = obj.start;
			}
			else if(obj.start >= start)
			{
				value += obj.value;
				end = obj.end;
			}
		}
	}
}