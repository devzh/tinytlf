package org.tinytlf.util.fte
{
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLineCreationResult;

	public class TextBlockUtil
	{
		public static function isInvalid(block:TextBlock):Boolean
		{
			return	block.firstLine == null || 
					block.firstInvalidLine || 
					block.textLineCreationResult != TextLineCreationResult.COMPLETE;
		}
		
		public static function cleanBlock(block:TextBlock):void
		{
			if(block.firstLine && block.lastLine)
				block.releaseLines(block.firstLine, block.lastLine);
			
			block.releaseLineCreationData();
			block.content = null;
			block.userData = null;
		}
	}
}