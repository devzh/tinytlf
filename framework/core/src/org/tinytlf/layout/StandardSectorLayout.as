package org.tinytlf.layout
{
	import flash.text.engine.*;
	
	import org.tinytlf.layout.alignment.*;
	import org.tinytlf.layout.progression.*;
	import org.tinytlf.layout.sector.*;
	
	public class StandardSectorLayout implements ISectorLayout
	{
		public function StandardSectorLayout(aligner:IAligner = null, progression:IProgressor = null)
		{
			a = aligner;
			p = progression;
		}
		
		public function layout(lines:Array, sector:TextSector):Array/*<TextLine>*/
		{
			lines.forEach(function(line:TextLine, ... args):void{
				line.y = p.progress(sector, line.previousLine) + line.ascent;
				line.x = a.getStart(sector, line);
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