/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.content
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.engine.*;
	
	import org.tinytlf.decoration.*;
	import org.tinytlf.html.IDOMNode;
	import org.tinytlf.interaction.*;
	import org.tinytlf.style.*;
	
	public class CEFactory implements IContentElementFactory
	{
		[Inject]
		public var decorator:ITextDecorator;
		
		[Inject]
		public var emm:IEventMirrorMap;
		
		[Inject]
		public var eff:IElementFormatFactory;
		
		[Inject]
		public var cefm:IContentElementFactoryMap;
		
		public function create(dom:IDOMNode):ContentElement
		{
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
			
			if(!(element is GroupElement))
			{
				//Do any decorations for this element.
				decorator.decorate(element, dom, dom['layer'], dom['foreground']);
			}
			
			return element;
		}
	}
}

