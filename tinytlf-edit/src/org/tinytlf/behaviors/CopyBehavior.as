package org.tinytlf.behaviors
{
	import org.tinytlf.model.ITLFNode;

	public class CopyBehavior extends OperationFactoryBehavior
	{
		[Event("copy")]
		public function copy():void
		{
			var out:ITLFNode = model.clone(selection.x, selection.y);
		}
	}
}