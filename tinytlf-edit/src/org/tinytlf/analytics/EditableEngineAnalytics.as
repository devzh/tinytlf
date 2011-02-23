package org.tinytlf.analytics
{
	import org.tinytlf.model.ITLFNode;

	public class EditableEngineAnalytics extends TextEngineAnalytics
	{
		public function EditableEngineAnalytics()
		{
			super();
		}
		
		override public function get contentLength():int
		{
			var root:ITLFNode = engine.blockFactory.data as ITLFNode;
			return root ? root.length : super.contentLength;
		}
	}
}