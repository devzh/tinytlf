/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout.model.factories.xhtml.adapters
{
	import flash.text.engine.ContentElement;
	import flash.text.engine.GroupElement;
	
	import org.tinytlf.layout.model.factories.ContentElementFactory;
	import org.tinytlf.layout.model.factories.IContentElementFactory;
	import org.tinytlf.layout.model.factories.ILayoutFactoryMap;
	import org.tinytlf.layout.model.factories.xhtml.XMLDescription;
	
	public class XMLElementAdapter extends ContentElementFactory
	{
		override public function execute(data:Object, ... context:Array):ContentElement
		{
			if(data is XML)
			{
				var node:XML = (data as XML);
				
				if(node.nodeKind() == 'text')
				{
					return super.execute(null, [node.toString()].concat(context));
				}
				
				var name:String = node.localName().toString();
				
				if(node..*.length() == 1)
				{
					return blockFactory.getElementFactory(name).execute.apply(null, [node.text().toString()].concat(context));
				}
				
				if(node..*.length() > 1)
				{
					var elements:Vector.<ContentElement> = new <ContentElement>[];
					var adapter:IContentElementFactory;
					
					for each(var child:XML in node.*)
					{
						adapter = blockFactory.getElementFactory(child.localName());
						
						if(child.nodeKind() == "text")
							elements.push(super.execute.apply(null, [child.toString()].concat(context)));
						else
							elements.push(adapter.execute.apply(null, [child].concat(context, new XMLDescription(child))));
					}
					
					return new GroupElement(elements, getElementFormat(Vector.<XMLDescription>(context)));
				}
			}
			
			var element:ContentElement = super.execute.apply(null, [data].concat(context));
			element.userData = Vector.<XMLDescription>(context);
			
			return element;
		}
		
		protected function get blockFactory():ILayoutFactoryMap
		{
			return engine.layout.textBlockFactory;
		}
	}
}