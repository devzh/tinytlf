package org.tinytlf.interaction.operations
{
	import flash.text.engine.TextBlock;
	
	import org.tinytlf.model.*;

	public class SplitParagraphOperation extends TextOperation
	{
		public function SplitParagraphOperation(props:Object=null)
		{
			super(props);
		}
		
		public var caret:int;
		public var nodeIndex:int;
		
		override public function execute():void
		{
			var root:ITLFNodeParent = ITLFNodeParent(model);
			nodeIndex = root.getChildIndexAtPosition(caret);
			var child:ITLFNode = root.getChildAt(nodeIndex);
			child.split(caret - root.getChildPosition(nodeIndex));
			engine.analytics.addBlockAt(new TextBlock(), nodeIndex + 1);
		}
		
		override public function backout():void
		{
			engine.analytics.removeBlockAt(nodeIndex + 1);
			var root:ITLFNodeParent = ITLFNodeParent(model);
			var pos:int = root.getChildPosition(nodeIndex);
			root.merge(pos, pos + 1);
		}
	}
}