package org.tinytlf.interaction.behaviors
{
	import org.tinytlf.model.ITLFNode;

	public class BackspaceBehavior extends MultiGestureBehavior
	{
		public function BackspaceBehavior()
		{
			super();
		}
		
		[Event("keyDown")]
		public function backspace():void
		{
			var model:ITLFNode = engine.layout.textBlockFactory.data as ITLFNode;
			if(!model)
				return;
			
			var index:int = engine.caretIndex;
			model.remove(index - 1, index);
			--engine.caretIndex;
			engine.invalidate();
		}
	}
}