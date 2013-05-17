package org.tinytlf.html
{
	import flash.geom.Rectangle;
	
	import org.tinytlf.TTLFBlock;

	public class TableRow extends Container
	{
		public function TableRow()
		{
			super();
		}
		
		override protected function continueRender(child:TTLFBlock):Boolean {
			return true;
		}
	}
}