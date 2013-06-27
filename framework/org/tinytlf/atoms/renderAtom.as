package org.tinytlf.atoms
{
	import flash.geom.Point;
	
	import org.tinytlf.Element;

	/**
	 * @author ptaylor
	 */
	public function renderAtom(px:Number, py:Number, initialize:Function, render:Function):Function {
		
		return function(element:Element, formatted:Boolean):Function {
			
			if(formatted == false) {
				
				const position:Point = element.offset(int(element.displayed('inline') == false));
				
				var rx:Number = 0;
				var ry:Number = 0;
				
				// If the element is relatively positioned, set the position from normal
				// flow, but visually offset it (and all children) by the top and left
				// properties from CSS.
				if(element.positioned('relative')) {
					rx += element.left;
					ry += element.top;
				}
				
				const gx:Number = px + position.x + rx;
				const gy:Number = py + position.y + ry;
				
				element.move(gx, gy, Element.GLOBAL);
				
				initialize(element);
				
				return renderAtom(gx, gy, initialize, render);
			}
			
			render(element);
			
			return null;
		}
	}
}
