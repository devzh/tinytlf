package org.tinytlf.interaction.behaviors
{
	import flash.text.engine.TextBlock;
	
	import org.tinytlf.model.ITLFNode;
	import org.tinytlf.model.ITLFNodeParent;
	import org.tinytlf.util.fte.TextBlockUtil;

	public class ShiftEnterBehavior extends MultiGestureBehavior
	{
		public function ShiftEnterBehavior()
		{
			super();
		}
		
		[Event("keyDown")]
		public function down():void
		{
			var model:ITLFNodeParent = engine.layout.textBlockFactory.data as ITLFNodeParent;
			if(!model)
				return;
			
			var caret:int = engine.caretIndex;
			
			var index:int = model.getChildIndexAtPosition(caret);
			
			var child:ITLFNode = model.getChildAt(index);
			child.split(caret - model.getChildPosition(index));
			
			engine.analytics.addBlockAt(new TextBlock(), index + 1);
			engine.invalidate();
		}
	}
}