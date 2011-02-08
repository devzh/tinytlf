package org.tinytlf.behaviors
{
	public class RedoBehavior extends OperationFactoryBehavior
	{
		[Event("keyDown")]
		public function redo():void
		{
			interactor.redo().execute();
		}
	}
}