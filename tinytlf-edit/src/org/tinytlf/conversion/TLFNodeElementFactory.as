package org.tinytlf.conversion
{
	import flash.display.Bitmap;
	import flash.text.engine.*;
	
	import org.tinytlf.model.*;
	import org.tinytlf.util.TinytlfUtil;
	import org.tinytlf.util.fte.ContentElementUtil;
	import org.tinytlf.utils.reflect;

	public class TLFNodeElementFactory extends ContentElementFactory
	{
		override public function execute(data:Object, ...parameters):ContentElement
		{
			var node:ITLFNode = data as ITLFNode;
			if(!node)
				return super.execute.apply(null, [data].concat(parameters));
			
			//Check to see if the node needs to be re-created.
			if(!verify(node))
				return node.contentElement = node.contentElement ? 
					update(node) : 
					create(node);
			
			return node.contentElement;
		}
		
		/**
		 * @private
		 * Verifies the ContentElement matches the properties and child nodes
		 * of the given ITLFNode.
		 * 
		 * @return True if the ContentElement is in sync with the node, False
		 * if the ContentElement needs to be re-generated.
		 */
		protected function verify(node:ITLFNode):Boolean
		{
			var element:ContentElement = node.contentElement;
			// Early exit if we've never created the node before.
			if(!element)
				return false;
			
			// If the elementFormat doesn't match with the properties on the
			// node, return false to run it through the parser again.
			if(!checkElementFormat(node, element))
				return false;
			
			// If it's a Container, check all its children. Return true after
			// verifying each child.
			if(node.type == TLFNodeType.CONTAINER)
			{
				// Not a Group but is a Container? Run it through the parser again.
				if(!(element is GroupElement))
					return false;
				
				var parent:ITLFNodeParent = node as ITLFNodeParent;
				var group:GroupElement = element as GroupElement;
				
				// If a node was added or removed, remove all the GroupElement's
				// children so they're sorted properly below.
				if(parent.numChildren != group.elementCount)
					ContentElementUtil.removeChildren(group);
				
				var child:ITLFNode;
				
				for(var i:int = 0, n:int = parent.numChildren; i < n; i += 1)
				{
					child = parent.getChildAt(i);
					
					// Assuming the return from getElementFactory() is a 
					// TLFNodeElementFactory, this will verify or recreate each
					// child contentElement. We do this because we've passed
					// all the other requirements for verification: this node's
					// ContentElement doesn't need re-creation. Therefore we'll
					// do this check and return true, meaning don't create
					// a different GroupElement instance for this node.
					// 
					// Of course, if the return from getElementFactory() isn't a
					// TLFNodeElementFactory or descendant, we want to call this
					// regardless, to be safe.
					child.contentElement = getElementFactory(child.name).execute(child);
					
					if(group.elementCount > i)
					{
						if(child.contentElement == group.getElementAt(i))
							continue;
						
						ContentElementUtil.removeChildAt(group, i);
					}
					
					ContentElementUtil.addChildAt(group, child.contentElement, i);
				}
				
				//All's clear.
				return true;
			}
			
			// The other type I care about right now is text-leaf nodes.
			// Eventually expand this to work with GraphicElement nodes and
			// the zero-width GraphicElements I inject into the FTE model to
			// force layout to do my bidding.
			if(element is TextElement)
			{
				var text:TextElement = element as TextElement;
				if(text.text !== node.text)
					return false;
			}
			
			return true;
		}
		
		/**
		 * @private
		 * Updates the ContentElement of the given ITLFNode.
		 * 
		 * @return The updated ContentElement instance.
		 */
		protected function update(node:ITLFNode):ContentElement
		{
			var element:ContentElement = node.contentElement;
			
			if(!checkElementFormat(node, element))
				element.elementFormat = getElementFormat(node);
			
			// Don't apply eventMirrors to GroupElements. That's my only request.
			if(!(element is GroupElement))
			{
				element.eventMirror = getEventMirror(node);
				engine.decor.decorate(element, node);
			}
			
			if(node.type == TLFNodeType.LEAF)
			{
				var text:TextElement = element as TextElement;
				text.text = node.text;
			}
			
			element.userData = node;
			
			return element;
		}
		
		/**
		 * @private
		 * Creates the ContentElement for the ITLFNode.
		 */
		protected function create(node:ITLFNode):ContentElement
		{
			var element:ContentElement;
			if(node.type == TLFNodeType.CONTAINER)
			{
				var parent:ITLFNodeParent = node as ITLFNodeParent;
				var child:ITLFNode;
				var elements:Vector.<ContentElement> = new <ContentElement>[];
				
				for(var i:int = 0, n:int = parent.numChildren; i < n; i += 1)
				{
					child = parent.getChildAt(i);
					elements.push(getElementFactory(child.name).execute(child));
				}
				
				element = new GroupElement(elements, getElementFormat(node));
			}
			else if(node.type == TLFNodeType.LEAF)
			{
				if(node.text == '')
					element = new GraphicElement(new Bitmap(), 0, 0, getElementFormat(node), getEventMirror(node));
				else
					element = new TextElement(node.text, getElementFormat(node), getEventMirror(node));
				
				engine.decor.decorate(element, node);
			}
			
			element.userData = node;
			return node.contentElement = element;
		}
		
		/**
		 * @private
		 * Checks only the properties of the ElementFormat and FontDescription
		 * against the input ITLFNode.
		 * 
		 * @return True if they match exactly, false otherwise.
		 */
		protected function checkElementFormat(node:ITLFNode, element:ContentElement):Boolean
		{
			var format:ElementFormat = element.elementFormat;
			var fontDescription:FontDescription = format.fontDescription;
			return (
				compareLikeSealedProperties(node, format) && 
				compareLikeSealedProperties(node, fontDescription)
			);
		}
		
		protected function getElementFactory(element:*):IContentElementFactory
		{
			return engine.blockFactory.getElementFactory(element);
		}
		
		private function compareLikeSealedProperties(toObj:Object, withObj:Object):Boolean
		{
			var sealedProperties:XMLList = reflect(withObj)..accessor.(@access == 'readwrite');
			var propName:String = '';
			
			for each(var prop:XML in sealedProperties)
			{
				propName = prop.@name;
				if(!(propName in toObj))
					continue;
				
				if(toObj[propName] !== withObj[propName])
					return false;
			}
			
			return true;
		}
	}
}