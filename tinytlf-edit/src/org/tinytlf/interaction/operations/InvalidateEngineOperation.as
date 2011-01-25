package org.tinytlf.interaction.operations
{
	public class InvalidateEngineOperation extends TextOperation
	{
		public function InvalidateEngineOperation(props:Object=null)
		{
			super(props);
		}
		
		override public function execute():void
		{
			engine.invalidate();
		}
		
		override public function backout():void
		{
			engine.invalidate();
		}
	}
}