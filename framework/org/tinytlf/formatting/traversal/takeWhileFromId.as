package org.tinytlf.formatting.traversal
{
	import flash.geom.Point;
	
	import org.tinytlf.Edge;
	import org.tinytlf.Element;
	import org.tinytlf.formatting.traversal.takeWhileFromPoint;
	
	import trxcllnt.ds.HRTree;
	
	/**
	 * @author ptaylor
	 */
	public function takeWhileFromId(id:String, width:Number, height:Number):Function {
		
		return function(element:Element, cache:HRTree, layout:Function):Function {
			
			var factory:Function;
			
			if(element.id == id) {
				factory = takeWhileFromPoint(new Point(element.x, element.y), width, height);
				return factory(element, cache, layout);
			}
			
			return function(...args):Function {
				
				if(args.length > 0) {
					const child:Element = args[0];
					factory = takeWhileFromId(id, width, height);
					return factory.apply(null, args);
				}
				
				// TODO: Return a predicate that stops rendering after a child
				// with the specified ID has been discovered and we've rendered
				// the rest of the children that fit into the width and height.
				
				var siblingWithId:Element;
				var predicate:Function;
				
				return function(child:Element):Boolean {
					
					if(siblingWithId == null) {
						if(child.id == id) siblingWithId = child;
						return true;
					} else if(predicate == null) {
						factory = takeWhileFromPoint(siblingWithId)(new Point(siblingWithId.x, siblingWithId.y), width, height);
						predicate = factory(element, cache, layout);
					}
					
					return predicate(child);
				}
			}
		}
	}
}
