package org.tinytlf.layout.sector
{
	import flash.text.engine.*;
	
	import org.tinytlf.util.*;
	import org.tinytlf.layout.alignment.IAligner;
	import org.tinytlf.layout.progression.IProgressor;
	
	internal class StandardSectorRenderer implements ISectorRenderer
	{
		public function StandardSectorRenderer(aligner:IAligner = null, progression:IProgressor = null)
		{
			a = aligner;
			p = progression;
		}
		
		public function render(block:TextBlock, region:TextSector = null):Array /*<TextLine>*/
		{
			var lines:Array = TextBlockUtil.getValidLines(block);
			
			if(TextBlockUtil.isInvalid(block))
			{
				lines = lines.concat(createLines(
									 block,
									 TextBlockUtil.getFirstValidLineBeforeInvalidLine(block),
									 region));
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
		
		protected var a:IAligner;
		
		public function set aligner(value:IAligner):void
		{
			a = value;
		}
		
		protected var p:IProgressor;
		
		public function set progressor(value:IProgressor):void
		{
			p = value;
		}
	}
}
