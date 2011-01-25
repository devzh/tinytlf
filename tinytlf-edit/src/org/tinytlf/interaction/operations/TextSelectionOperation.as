package org.tinytlf.interaction.operations
{
	import flash.geom.Point;
	
	import org.tinytlf.ITextEngine;

	public class TextSelectionOperation extends TextOperation
	{
		public function TextSelectionOperation(props:Object=null)
		{
			super(props);
		}
		
		public var selection:Point;
		private var start:Point;
		
		override public function execute():void
		{
			start = engine.selection.clone();
			engine.select(selection ? selection.x : NaN, selection ? selection.y : NaN);
		}
		
		override public function backout():void
		{
			selection = engine.selection.clone();
			engine.select(start ? start.x : NaN, start ? start.y : NaN);
		}
	}
}