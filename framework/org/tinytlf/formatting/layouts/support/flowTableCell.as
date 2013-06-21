package org.tinytlf.formatting.layouts.support
{
	import asx.array.last;
	
	import org.tinytlf.Element;
	import org.tinytlf.enum.TextAlign;
	
	/**
	 * @author ptaylor
	 */
	public function flowTableCell(flowed:Array,
								  container:Element,
								  element:Element):Element {
		
		const collaborator:Element = last(flowed) as Element;
		
		const float:Function = element.textAlign == TextAlign.RIGHT ? floatRight : floatLeft;
		const floatSide:String = element.textAlign == TextAlign.RIGHT ? 'left' : 'right';
		
		// TODO: Is there a better way to get the colgroup?
		const node:XML = element.node;
		const tr:XML = node.parent();
		const tbody:XML = tr.parent();
		const table:XML = (tbody.localName() == 'table') ? tbody : tbody.parent();
		const colgroup:XML = table.colgroup[0];
		
		var cellWidth:Number = NaN;
		
		if(colgroup) {
			cellWidth = getCellWidth(colgroup.col, tr.td, element.index);
			// Set the width as a style so it'll take precedence over
			// measured sizes.
			if(cellWidth == cellWidth) element.setStyle('width', cellWidth);
		}
		
		if(collaborator == null || collaborator == container) return float(container, null, null, element);
		
		return float(container, collaborator, null, element);
	}
}

import org.tinytlf.xml.mergeAttributes;

import trxcllnt.Store;

internal function getCellWidth(cols:XMLList, cells:XMLList, index:int):Number {
	
	var cell:int = -1;
	var col:int = 0;
	var width:Number = 0;
	const store:Store = new Store();
	
	while(++cell <= index) {
		
		width = 0;
		
		mergeAttributes(store, cells[cell]);
		
		const end:int = col + (int(store.colspan) || 1);
		
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