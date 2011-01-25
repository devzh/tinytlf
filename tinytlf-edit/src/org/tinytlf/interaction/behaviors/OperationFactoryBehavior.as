package org.tinytlf.interaction.behaviors
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.tinytlf.interaction.IEditInteractor;
	import org.tinytlf.interaction.operations.ITextOperation;
	import org.tinytlf.model.ITLFNode;

	public class OperationFactoryBehavior extends MultiGestureBehavior
	{
		protected var model:ITLFNode;
		protected var interactor:IEditInteractor;
		
		override protected function act(events:Vector.<Event>):void
		{
			model = engine.layout.textBlockFactory.data as ITLFNode;
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