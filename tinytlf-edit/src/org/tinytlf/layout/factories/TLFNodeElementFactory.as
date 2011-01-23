package org.tinytlf.layout.factories
{
	import flash.display.Bitmap;
	import flash.text.engine.*;
	
	import org.tinytlf.model.*;

	public class TLFNodeElementFactory extends ContentElementFactory
	{
		override public function execute(data:Object, ...parameters):ContentElement
		{
			var node:ITLFNode = data as ITLFNode;
			if(!node)
				return super.execute.apply(null, [data].concat(parameters));
			
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
		
		protected function getElementFactory(element:*):IContentElementFactory
		{
			return engine.layout.textBlockFactory.getElementFactory(element);
		}
	}
}