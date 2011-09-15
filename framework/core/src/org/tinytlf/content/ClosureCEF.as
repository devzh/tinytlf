package org.tinytlf.content
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.engine.*;
	
	import org.swiftsuspenders.*;
	import org.tinytlf.decoration.*;
	import org.tinytlf.html.*;
	import org.tinytlf.interaction.*;
	import org.tinytlf.style.*;
	
	public class ClosureCEF implements IContentElementFactory
	{
		[Inject]
		public var cefm:IContentElementFactoryMap;
		[Inject]
		public var decorator:ITextDecorator;
		[Inject]
		public var emm:IEventMirrorMap;
		[Inject]
		public var eff:IElementFormatFactory;
		[Inject]
		public var injector:Injector;
		
		public function ClosureCEF(closure:Function = null)
		{
			createFunc = closure || function(dom:IDOMNode):ContentElement {
				var element:ContentElement;
				
				if(dom.children.length)
				{
					const elements:Vector.<ContentElement> = new <ContentElement>[];
					dom.children.forEach(function(child:IDOMNode, ... args):void {
						elements.push(cefm.instantiate(child.name).create(child));
					});
					element = new GroupElement(elements, eff.getElementFormat(dom), new EventDispatcher());
				}
				else if(dom.text)
				{
					element = new TextElement(dom.text, eff.getElementFormat(dom));
				}
				else
				{
					element = new GraphicElement(new Shape(), 0, 0, eff.getElementFormat(dom));
				}
				
				if(!element)
					return null;
				
				// Associate these objects with each other.
				dom.content = element;
				element.userData = dom;
				dom.mirror = emm.instantiate(dom);
				
				if(!(element is GroupElement))
				{
					//Do any decorations for this element.
					decorator.decorate(element, dom, dom['layer'], dom['foreground']);
				}
				
				return element;
			};
		}
		
		private var createFunc:Function;
		
		public function create(dom:IDOMNode):ContentElement
		{
			return createFunc(dom);
		}
	}
}
