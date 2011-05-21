package org.tinytlf.behaviors
{
	import flash.events.Event;
	
	import org.tinytlf.conversion.IHTMLNode;
	import org.tinytlf.interaction.IEditInteractor;
	import org.tinytlf.operations.ITextOperation;

	public class OperationFactoryBehavior extends MultiGestureBehavior
	{
		protected var model:IHTMLNode;
		protected var interactor:IEditInteractor;
		
		override protected function act(events:Vector.<Event>):void
		{
			model = engine.blockFactory.data as IHTMLNode;
			interactor = engine.interactor as IEditInteractor;
			
			if(!model || !interactor)
				return;
			
			super.act(events);
		}
		
		protected function push(op:ITextOperation):ITextOperation
		{
			return interactor.push(op);
		}
		
		protected function initAndExecute(...ops):void
		{
			ops.forEach(ieCallback);
		}
		
		private function ieCallback(op:ITextOperation, ...args):void
		{
			op.initialize(model).execute();
		}
	}
}