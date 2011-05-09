package org.tinytlf.conversion
{
	import flash.events.EventDispatcher;
	import flash.text.engine.ContentElement;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.GroupElement;
	import flash.text.engine.TextElement;

	public class HTMLNodeElementFactory extends ContentElementFactory
	{
		override public function execute(data:Object, ...parameters):ContentElement
		{
			if(data is IHTMLNode)
			{
				var node:IHTMLNode = data as IHTMLNode;
				var n:int = node.children.length();
				
				var element:ContentElement;
				var ef:ElementFormat = getElementFormat(node);
				var em:EventDispatcher = getEventMirror(node.name);
				
				if(n <= 1)
				{
					element = new TextElement(node.text, ef, em);
				}
				else
				{
					var factory:ITextBlockFactory = engine.blockFactory;
					var elements:Vector.<ContentElement> = new <ContentElement>[];
					var children:XMLList = node.children;
					var child:IHTMLNode;
					
					for(var i:int = 0; i < n; ++i)
					{
						child = new HTMLNode(children[i], node);
						child.mergeWith(node);
						child.mergeWith(engine.styler.describeElement(child.inheritanceList.split(' ')));
						
						elements.push(factory.getElementFactory(child.name).execute(child));
					}
					
					element = new GroupElement(elements, ef);
				}
				
				element.userData = node;
				return element;
			}
			
			return super.execute.apply([data].concat(parameters));
		}
	}
}