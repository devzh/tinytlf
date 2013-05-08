package org.tinytlf.html
{
	import flash.geom.Rectangle;
	
	import org.tinytlf.TTLFBlock;
	import org.tinytlf.fn.mergeAttributes;
	import org.tinytlf.fn.wrapTextNodes;
	
	import trxcllnt.Store;

	public class TableCell extends Container
	{
		public function TableCell(node:XML)
		{
			super(node);
			
			setStyle('float', 'left');
		}
		
		override public function update(value:XML, viewport:Rectangle):TTLFBlock {
			
			_index = value.childIndex();
			mergeAttributes(styles, wrapTextNodes(value));
			
			// TODO: Is there a better way to get the colgroup?
			const tr:XML = value.parent();
			const tbody:XML = tr.parent();
			const table:XML = (tbody.localName() == 'table') ? tbody : tbody.parent();
			const colgroup:XML = table.colgroup[0];
			
			const width:Number = getCellWidth(colgroup.col, tr.td, index);
			if(width == width) {
				setStyle('width', width);
			}
			
			return super.update(value, viewport);
		}
		
		private function getCellWidth(cols:XMLList, cells:XMLList, index:int):Number {
			
			var cell:int = -1;
			var col:int = 0;
			var width:Number = 0;
			const store:Store = new Store();
				
			while(++cell <= index) {
				
				mergeAttributes(store, cells[cell]);
				
				const end:int = col + (store.colspan || 1);
				
				while(col < end) {
					
					if(col >= cols.length()) return NaN;
					
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