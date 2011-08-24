package org.tinytlf.layout.sector
{
	import flash.text.engine.*;
	import org.tinytlf.layout.alignment.IAligner;
	import org.tinytlf.layout.progression.IProgressor;
	
	internal class StandardSectorLayout implements ISectorLayout
	{
		public function StandardSectorLayout(aligner:IAligner = null, progression:IProgressor = null)
		{
			a = aligner;
			p = progression;
		}
		
		public function layout(lines:Array, region:TextSector = null):Array/*<TextLine>*/
		{
			lines.forEach(function(line:TextLine, ... args):void{
				line.y = p.progress(region, line.previousLine) + line.ascent;
				line.x = a.getStart(region, line);
			});
			
			return lines;
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