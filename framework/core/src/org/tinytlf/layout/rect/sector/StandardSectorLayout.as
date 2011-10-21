package org.tinytlf.layout.rect.sector
{
	import flash.text.engine.*;
	
	import org.tinytlf.layout.alignment.*;
	import org.tinytlf.layout.progression.*;
	
	public class StandardSectorLayout implements ISectorLayout
	{
		public function StandardSectorLayout(progression:IProgression = null)
		{
			p = progression;
		}
		
		public function layout(lines:Array, sector:TextSector):Array /*<TextLine>*/
		{
			lines.forEach(function(line:TextLine, ... args):void {
				p.position(sector, line);
//				a.position(sector, line);
			});
			
			return lines.concat();
		}
		
		protected var p:IProgression;
		public function get progression():IProgression
		{
			return p;
		}
		
		public function set progression(value:IProgression):void
		{
			p = value;
		}
	}
}
