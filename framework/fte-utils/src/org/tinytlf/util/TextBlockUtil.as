package org.tinytlf.util
{
	import flash.text.engine.*;
	
	public final class TextBlockUtil
	{
		public static function isInvalid(block:TextBlock):Boolean
		{
			return block.firstLine == null ||
				block.firstInvalidLine ||
				block.textLineCreationResult != TextLineCreationResult.COMPLETE;
		}
		
		public static function getFirstValidLineBeforeInvalidLine(block:TextBlock):TextLine
		{
			var line:TextLine = block.firstInvalidLine;
			
			while(line)
			{
				if(line.validity == TextLineValidity.VALID)
					break;
				
				line = line.previousLine;
			}
			
			return line;
		}
		
		public static function getValidLines(block:TextBlock):Array /*<TextLine>*/
		{
			const lines:Array = [];
			var line:TextLine = block.firstLine;
			var valid:Boolean = true;
			
			while(line)
			{
				if(line.validity != TextLineValidity.VALID)
					valid = false;
				
				if(valid)
					lines.push(line);
				else
					TextLineUtil.checkIn(TextLineUtil.cleanLine(line));
				
				line = line.nextLine;
			}
			
			return lines;
		}
		
		public static function cleanBlock(block:TextBlock):void
		{
			if(!block)
				return;
			
			if(block.firstLine)
				block.releaseLines(block.firstLine, block.lastLine);
			
			block.releaseLineCreationData();
			block.content = null;
			block.userData = null;
		}
		
		private static const blocks:Vector.<TextBlock> = new <TextBlock>[];
		public static function checkIn(block:TextBlock):void
		{
			if(!block)
				return;
			
			cleanBlock(block);
			blocks.push(block);
		}
		
		public static function checkOut():TextBlock
		{
			return blocks.pop() || new TextBlock();
		}
	}
}
