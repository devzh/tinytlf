package org.tinytlf.layout
{
	import flash.text.engine.*;
	
	import org.tinytlf.util.*;
	
	internal class StandardBlockRenderer implements IBlockRenderer
	{
		public function StandardBlockRenderer(aligner:IBlockAligner = null, progression:IBlockProgressor = null)
		{
			a = aligner;
			p = progression;
		}
		
		public function render(block:TextBlock,
							   region:TextSector = null,
							   constraints:Array = null):Array /*<TextLine>*/
		{
			var lines:Array = TextBlockUtil.getValidLines(block);
			var line:TextLine;
			
			if(TextBlockUtil.isInvalid(block))
			{
				if(block.firstInvalidLine)
					line = block.firstInvalidLine.previousLine;
				else if(block.textLineCreationResult != TextLineCreationResult.COMPLETE)
					line = block.lastLine;
				
				lines = lines.concat(createLines(block, line, region));
			}
			
			return lines.concat();
		}
		
		private function createLines(block:TextBlock, pLine:TextLine, region:TextSector):Array /*<TextLine>*/
		{
			const lines:Array = [];
			
			var line:TextLine = pLine;
			
			while(true)
			{
				line = createTextLine(block, line, a.getSize(region, line));
				
				if(line == null)
					break;
				
				lines.push(line);
			}
			
			return lines;
		}
		
		protected function createTextLine(block:TextBlock, previousLine:TextLine, width:Number):TextLine
		{
			const orphan:TextLine = TextLineUtil.checkOut();
			return orphan ?
				block.recreateTextLine(orphan, previousLine, width, 0.0, true) :
				block.createTextLine(previousLine, width, 0.0, true);
		}
		
		protected var a:IBlockAligner;
		
		public function set aligner(value:IBlockAligner):void
		{
			a = value;
		}
		
		protected var p:IBlockProgressor;
		
		public function set progressor(value:IBlockProgressor):void
		{
			p = value;
		}
	}
}