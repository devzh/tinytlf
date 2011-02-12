/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.conversion
{
	import flash.text.engine.*;
	
	public class XMLElementFactory extends ContentElementFactory
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
							elements.push(adapter.execute.apply(null, [child].concat(context, new XMLModel(child))));
					}
					
					return new GroupElement(elements, getElementFormat(Vector.<XMLModel>(context)));
				}
			}
			
			var element:ContentElement = super.execute.apply(null, [data].concat(context));
			element.userData = Vector.<XMLModel>(context);
			
			return element;
		}
		
		protected function get blockFactory():ITextBlockFactory
		{
			return engine.blockFactory;
		}
	}
}