package org.tinytlf.interaction.behaviors
{
	public class UndoBehavior extends OperationFactoryBehavior
	{
		[Event("keyDown")]
		public function undo():void
		{
			interactor.undo().backout();
		}
	}
}