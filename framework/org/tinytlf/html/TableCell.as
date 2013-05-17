package org.tinytlf.html
{
	import org.tinytlf.xml.mergeAttributes;
	
	import trxcllnt.Store;

	public class TableCell extends Container
	{
		public function TableCell()
		{
			super();
		}
		
		override protected function draw():void {
			
			setStyle('float', 'left');
			
			const node:XML = XML(content);
			
			// TODO: Is there a better way to get the colgroup?
			const tr:XML = node.parent();
			const tbody:XML = tr.parent();
			const table:XML = (tbody.localName() == 'table') ? tbody : tbody.parent();
			const colgroup:XML = table.colgroup[0];
			
			const cellWidth:Number = getCellWidth(colgroup.col, tr.td, index);
			
			if(cellWidth == cellWidth) {
				actualWidth = cellWidth;
			}
			
			super.draw();
		}
		
		private function getCellWidth(cols:XMLList, cells:XMLList, index:int):Number {
			
			var cell:int = -1;
			var col:int = 0;
			var width:Number = 0;
			const store:Store = new Store();
			
			while(++cell <= index) {
				width = 0;
				
				mergeAttributes(store, cells[cell]);
				
				const end:int = col + (store.colspan || 1);
				
				while(col < end) {
					
					if(col >= cols.length()) return width || NaN;
					
					width += mergeAttributes(store, cols[col]).width;
					
					++col;
				}
				
				delete store['colspan'];
				delete store['width'];
			}
			
			return width;
		}
	}
}