package org.tinytlf.layout
{
	import flash.text.engine.*;
	
	internal class StandardBlockLayout implements IBlockLayout
	{
		public function StandardBlockLayout(aligner:IBlockAligner = null, progression:IBlockProgressor = null)
		{
			a = aligner;
			p = progression;
		}
		
		public function layout(lines:Array,
							   region:TextSector = null,
							   constraints:Array = null):Array/*<TextLine>*/
		{
			lines.forEach(function(line:TextLine, ... args):void{
				line.y = p.progress(region, line.previousLine) + line.ascent;
				line.x = a.getStart(region, line);
			});
			
			return lines;
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