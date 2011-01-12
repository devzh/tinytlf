package org.tinytlf.util.fte
{
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLineCreationResult;

	public final class TextBlockUtil
	{
		public static function isInvalid(block:TextBlock):Boolean
		{
			return	block.firstLine == null || 
					block.firstInvalidLine || 
					block.textLineCreationResult != TextLineCreationResult.COMPLETE;
		}
		
		public static function cleanBlock(block:TextBlock):void
		{
			if(block.firstLine)
				block.releaseLines(block.firstLine, block.lastLine);
			
			block.releaseLineCreationData();
			block.content = null;
			block.userData = null;
		}
		
		private static const blocks:Vector.<TextBlock> = new <TextBlock>[];
		public static function checkIn(block:TextBlock):void
		{
			cleanBlock(block);
			blocks.push(block);
		}
		
		public static function checkOut():TextBlock
		{
			return blocks.pop() || new TextBlock();
		}
	}
}