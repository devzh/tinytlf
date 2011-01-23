package org.tinytlf.layout.factories
{
	import flash.display.*;
	import flash.text.engine.*;
	
	public class XMLModelFactory extends ContentElementFactory
	{
		override public function execute(data:Object, ...parameters):ContentElement
		{
			var model:XMLModel = data as XMLModel;
			
			if(!model)
				return super.execute.apply(null, [data].concat(parameters));
			
			var element:ContentElement;
			if(model.type == 'text' || model..*.length <= 1)
			{
				element = (model.text.length == 0) ?
					new GraphicElement(new Shape(), 0, 0) :
					new TextElement(model.text);
				
				model.applyTo(element);
				
				element.elementFormat = getElementFormat(model);
				element.eventMirror = getEventMirror(model);
				
				engine.decor.decorate(element, model);
			}
			else
			{
				var elements:Vector.<ContentElement> = new <ContentElement>[];
				var n:int = model.numChildren;
				for(var i:int = 0; i < n; i += 1)
				{
					elements.push(model.getChildAt(i).generateContentElement());
				}
				
				element = new GroupElement(elements);
			}
			element.userData = model;
			
			return element;
		}
	}
}