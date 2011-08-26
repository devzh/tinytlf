package org.tinytlf.layout
{
	import flash.text.engine.*;
	
	import org.tinytlf.layout.alignment.*;
	import org.tinytlf.layout.progression.*;
	import org.tinytlf.layout.sector.*;
	import org.tinytlf.util.*;
	
	public class StandardSectorRenderer implements ISectorRenderer
	{
		public function StandardSectorRenderer(aligner:IAligner = null, progression:IProgressor = null)
		{
			a = aligner;
			p = progression;
		}
		
		public function render(block:TextBlock, sector:TextSector):Array /*<TextLine>*/
		{
			var lines:Array = TextBlockUtil.getValidLines(block);
			
			if(TextBlockUtil.isInvalid(block))
			{
				lines = lines.concat(createLines(
									 block,
									 TextBlockUtil.getFirstValidLineBeforeInvalidLine(block),
									 sector));
			}
			
			return lines.concat();
		}
		
		private function createLines(block:TextBlock, pLine:TextLine, sector:TextSector):Array /*<TextLine>*/
		{
			const lines:Array = [];
			
			var line:TextLine = pLine;
			
			while(true)
			{
				line = createTextLine(block, line, a.getSize(sector, line));
				
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
