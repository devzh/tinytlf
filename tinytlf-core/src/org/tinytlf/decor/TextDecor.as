/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.decor
{
	import org.tinytlf.ITextEngine;
	import org.tinytlf.layout.ITextContainer;
	
	////
	//  This renders every decoration again every time the decorations are 
	//  invalidated. Isn't there a way to know which decorations changed and
	//  only clear/render those? I mean without creating separate
	//  Shapes/Sprites per decoration (ick!).
	//  
	//  09/05/2010: did some testing tonight, seems this isn't as big a deal (yet)
	//  as I thought it could be. Will keep my eye on the situation.
	////
	
	/**
	 * The decoration actor for tinytlf.
	 *
	 * @see org.tinytlf.decor.ITextDecoration
	 */
	public class TextDecor implements ITextDecor
	{
		public static const CARET_LAYER:int = 1;
		public static const SELECTION_LAYER:int = 2;
		
		protected var _engine:ITextEngine;
		
		public function get engine():ITextEngine
		{
			return _engine;
		}
		
		public function set engine(textEngine:ITextEngine):void
		{
			if(textEngine == _engine)
				return;
			
			_engine = textEngine;
		}
		
		public function render():void
		{
			for each(var el:Element in elements)
			{
				el.decorations.sort(function(d1:Decoration, d2:Decoration):int
				{
					return d1.layer - d2.layer;
				});
				
				for each(var dec:Decoration in el.decorations)
				{
					dec.draw(dec.setup(el.element));
				}
			}
		}
		
		public function removeAll():void
		{
			for each(var el:Element in elements)
			{
				for each(var dec:Decoration in el.decorations)
				{
					el.removeDecoration(dec);
					dec.destroy();
				}
			}
			
			elements.length = 0;
		}
		
		private var elements:Vector.<Element> = new Vector.<Element>();
		
		public function decorate(element:*, styleObject:Object, layer:int = 2,
			container:ITextContainer = null, foreground:Boolean = false):void
		{
			var styleProp:String = String(styleObject);
			
			//  Early return optimizations not to loop or invalidate
			//  if there are no decorations in the styleObject.
			if(styleObject is String && !hasDecoration(styleProp))
				return;
			else
			{
				var hasOne:Boolean = false;
				for(styleProp in styleObject)
				{
					if(hasOne = hasDecoration(styleProp))
						break;
				}
				
				if(hasOne == false)
					return;
			}
			
			var el:Element = getElement(element);
			
			if(styleObject is String && hasDecoration(styleProp))
			{
				el.addDecoration(new Decoration(getDecoration(styleProp, container), layer));
			}
			else
			{
				var decoration:ITextDecoration;
				var dec:Decoration;
				var styleValue:*;
				
				for(styleProp in styleObject)
				{
					styleValue = styleObject[styleProp];
					//You can de-apply a decoration by passing in {decoration:false} or {decoration:null}
					if(styleValue === false || styleValue === 'false' || styleValue == null)
					{
						undecorate(element, styleProp);
					}
					else if(hasDecoration(styleProp))
					{
						dec = el.getDecoration(decorationsMap[styleProp]);
						if(dec)
						{
							decoration = dec.decoration;
							decoration.mergeWith(styleObject);
							continue;
						}
						
						decoration = getDecoration(styleProp, container);
						decoration.foreground = foreground;
						decoration.style = styleObject;
						el.addDecoration(new Decoration(decoration, layer));
					}
				}
			}
			
			engine.invalidateDecorations();
		}
		
		public function undecorate(element:* = null, decorationProp:String = null):void
		{
			if(element === null && decorationProp === null)
				return;
			
			var el:Element;
			var dec:Decoration;
			
			if(element)
			{
				el = getElement(element);
				
				if(!el)
					return;
				
				if(decorationProp)
				{
					if(!hasDecoration(decorationProp))
						return;
					
					dec = el.getDecoration(decorationsMap[decorationProp]);
					while(dec)
					{
						el.removeDecoration(dec);
						dec.destroy();
						dec = el.getDecoration(decorationsMap[decorationProp]);
					}
				}
				else
				{
					var decorations:Vector.<Decoration> = el.decorations.concat();
					for each(dec in decorations)
					{
						el.removeDecoration(dec);
						dec.destroy();
					}
				}
				
				cleanupElement(el);
			}
			else
			{
				if(!hasDecoration(decorationProp))
					return;
				
				var type:Class = decorationsMap[decorationProp];
				var ements:Vector.<Element> = elements.concat();
				
				for each(el in ements)
				{
					dec = el.getDecoration(type);
					if(dec)
					{
						el.removeDecoration(dec);
						dec.destroy();
						cleanupElement(el);
					}
				}
			}
			
			engine.invalidateDecorations();
		}
		
		protected var decorationsMap:Object = {};
		
		public function mapDecoration(styleProp:String, decorationClassOrFactory:Object):void
		{
			if(decorationClassOrFactory)
				decorationsMap[styleProp] = decorationClassOrFactory;
			else
				unMapDecoration(styleProp);
		}
		
		public function unMapDecoration(styleProp:String):Boolean
		{
			if(!hasDecoration(styleProp))
				return false;
			
			return delete decorationsMap[styleProp];
		}
		
		public function hasDecoration(decorationProp:String):Boolean
		{
			return Boolean(decorationProp in decorationsMap);
		}
		
		public function getDecoration(styleProp:String, container:ITextContainer = null):ITextDecoration
		{
			if(!hasDecoration(styleProp))
				return null;
			
			var decoration:* = decorationsMap[styleProp];
			if(decoration is Class)
				decoration = ITextDecoration(new decoration());
			else if(decoration is Function)
				decoration = ITextDecoration((decoration as Function)());
			
			if(!decoration)
				return null;
			
			ITextDecoration(decoration).container = container;
			
			ITextDecoration(decoration).engine = engine;
			
			return ITextDecoration(decoration);
		}
		
		protected function getElement(element:*):Element
		{
			var filter:Vector.<Element> = elements.filter(function(e:Element, ... args):Boolean
			{
				return e.element === element;
			});
			
			if(filter.length)
				return filter[0];
			
			var el:Element = new Element(element);
			elements.push(el);
			return el;
		}
		
		protected function cleanupElement(el:Element):void
		{
			if(el.decorations.length > 0)
				return;
			
			elements.splice(elements.indexOf(el), 1);
			el.decorations = null;
			el.element = null;
		}
	}
}

import flash.events.EventDispatcher;
import flash.geom.Rectangle;
import flash.text.engine.ContentElement;

import org.tinytlf.decor.ITextDecoration;

internal class Element
{
	public function Element(e:*)
	{
		this.element = e;
		
		if(e is ContentElement && ContentElement(e).eventMirror == null)
			ContentElement(e).eventMirror = new EventDispatcher();
	}
	
	public var element:*;
	public var decorations:Vector.<Decoration> = new Vector.<Decoration>();
	
	public function getDecoration(decorationType:Class):Decoration
	{
		var filter:Vector.<Decoration> = decorations.filter(function(d:Decoration, ... args):Boolean
		{
			return (d.decoration is decorationType);
		});
		
		return filter.length ? filter[0] : null;
	}
	
	public function addDecoration(decoration:Decoration):void
	{
		if(decorations.indexOf(decoration) == -1)
			decorations.push(decoration);
	}
	
	public function removeDecoration(decoration:Decoration):void
	{
		var i:int = decorations.indexOf(decoration);
		if(i != -1)
			decorations.splice(i, 1);
	}
}

internal class Decoration
{
	public function Decoration(decoration:ITextDecoration, layer:int = 2)
	{
		this.decoration = decoration;
		this.layer = layer;
	}
	
	public function destroy():void
	{
		decoration.destroy();
		decoration = null;
	}
	
	public function setup(... args):Vector.<Rectangle>
	{
		return decoration.setup.apply(null, [layer].concat(args));
	}
	
	public function draw(bounds:Vector.<Rectangle>):void
	{
		decoration.draw(bounds);
	}
	
	public var layer:int = 2;
	public var decoration:ITextDecoration;
}