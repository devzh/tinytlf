package org.tinytlf.operations
{
	import org.tinytlf.model.ITLFNode;

	public class CompositeOperation extends TextOperation
	{
		public function CompositeOperation(props:Object = null)
		{
			super(props);
		}
		
		private var operations:Vector.<ITextOperation> = new <ITextOperation>[];
		public function add(...ops):void
		{
			operations = operations.concat(Vector.<ITextOperation>(ops));
		}
		
		private var enders:Vector.<ITextOperation> = new <ITextOperation>[];
		public function runAtEnd(...ops):void
		{
			enders = enders.concat(Vector.<ITextOperation>(ops));
		}
		
		override public function initialize(model:ITLFNode):ITextOperation
		{
			super.initialize(model);
			
			operations.forEach(initCallback);
			enders.forEach(initCallback);
			
			return this;
		}
		
		override public function execute():void
		{
			operations.forEach(eCallback);
			enders.forEach(eCallback);
		}
		
		override public function backout():void
		{
			operations.concat().reverse().forEach(bCallback);
			enders.forEach(bCallback);
		}
		
		override public function merge(op:ITextOperation):void
		{
			super.merge(op);
			
			var composite:CompositeOperation = CompositeOperation(op);
			composite.operations.forEach(mCallback, this);
		}
		
		private function initCallback(op:ITextOperation, ...args):void
		{
			op.initialize(model)
		}
		
		private function eCallback(op:ITextOperation, ...args):void
		{
			op.execute();
		}
		
		private function bCallback(op:ITextOperation, ...args):void
		{
			op.backout();
		}
		
		private function mCallback(op:ITextOperation, index:int, ...args):void
		{
			operations[index].merge(op);
		}
	}
}