package org.tinytlf.interaction.behaviors
{
	import org.tinytlf.model.ITLFNode;
	import org.tinytlf.util.TinytlfUtil;
	import org.tinytlf.util.fte.TextLineUtil;

	public class BackspaceCtrlBehavior extends MultiGestureBehavior
	{
		public function BackspaceCtrlBehavior()
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
			var atomIndex:int = TinytlfUtil.globalIndexToAtomIndex(engine, line, index);
			var start:int = TextLineUtil.getAtomWordBoundary(line, atomIndex);
			if(start == atomIndex)
				start = TextLineUtil.getAtomWordBoundary(line, atomIndex - 1);
			
			model.remove(start, atomIndex);
			engine.caretIndex = TinytlfUtil.atomIndexToGlobalIndex(engine, line, start);
			engine.invalidate();
		}
	}
}