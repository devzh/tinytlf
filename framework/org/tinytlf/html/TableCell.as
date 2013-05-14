package org.tinytlf.html
{
	import flash.geom.Rectangle;
	
	import org.tinytlf.TTLFBlock;
	import org.tinytlf.xml.mergeAttributes;
	import org.tinytlf.xml.wrapTextNodes;
	
	import trxcllnt.Store;

	public class TableCell extends Container
	{
		public function TableCell(node:XML)
		{
			super(node);
		}
		
		override public function getStyle(style:String):* {
			if(style == 'float') return 'left';
			return super.getStyle(style);
		}
		
		override public function update(value:XML, viewport:Rectangle):Boolean {
			
			_index = value.childIndex();
			mergeAttributes(styles, wrapTextNodes(value));
			
			// TODO: Is there a better way to get the colgroup?
			const tr:XML = value.parent();
			const tbody:XML = tr.parent();
			const table:XML = (tbody.localName() == 'table') ? tbody : tbody.parent();
			const colgroup:XML = table.colgroup[0];
			
			const width:Number = getCellWidth(colgroup.col, tr.td, index);
			
			if(width == width) setStyle('width', width);
			
			return super.update(value, viewport);
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