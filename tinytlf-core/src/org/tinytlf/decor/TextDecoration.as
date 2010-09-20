/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.decor
{
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.text.engine.*;
    import flash.utils.*;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.layout.ITextContainer;
    import org.tinytlf.styles.StyleAwareActor;
    import org.tinytlf.util.fte.ContentElementUtil;

    public class TextDecoration extends StyleAwareActor implements ITextDecoration
    {
        public function TextDecoration(styleObject:Object = null)
        {
            super(styleObject);
        }
		private var _container:ITextContainer;
		
		public function get container():ITextContainer
		{
			return _container;
		}
		
		public function set container(textContainer:ITextContainer):void
		{
			if (textContainer === _container)
				return;
			
			_container = textContainer;
		}
		
		protected var _engine:ITextEngine;
		
		public function get engine():ITextEngine
		{
			return _engine;
		}
		
		public function set engine(textEngine:ITextEngine):void
		{
			if (textEngine == _engine)
				return;
			
			_engine = textEngine;
		}
		
		private var _foreground:Boolean = false;
		public function set foreground(value:Boolean):void
		{
			_foreground = value;
		}
		
		public function get foreground():Boolean
		{
			return _foreground;
		}
		
		protected var rectToContainer:Dictionary = new Dictionary(true);
		
		public function setup(layer:int = 2, ... args):Vector.<Rectangle>
		{
			var bounds:Vector.<Rectangle> = new <Rectangle>[];
			
			if (args.length <= 0)
				return bounds;
			
			var arg:* = args[0];
			var rect:Rectangle;
			
			var tl:TextLine;
			
			if (arg is ContentElement)
			{
				////
				//  When you decorate a ContentElement, there's no way to 
				//  associate it with the ITextContainer[s] that it renders in. 
				//  Here we grab every container that holds TextLines for the 
				//  element.
				//  
				//  @TODO
				//  It might be better if this exists somewhere else.
				//  Theoretically the ITextLayout's layout routine could update 
				//  ITextDecor's decorations that are keyed off ContentElements
				//  as the lines are rendering, but I'm almost certain this would
				//  require special API to stay efficient.
				////
				
				var tlmrs:Vector.<TextLineMirrorRegion> = ContentElementUtil.getMirrorRegions(ContentElement(arg));
				var tlmr:TextLineMirrorRegion;
				
				var n:int = tlmrs.length;
				for(var i:int = 0; i < n; ++i)
				{
					tlmr = tlmrs[i];
					rect = tlmr.bounds.clone();
					tl = tlmr.textLine;
					rect.offset(tl.x, tl.y);
					rectToContainer[rect] = 
						assureLayerExists(engine.layout.getContainerForLine(tl), layer)
					bounds.push(rect);
				}
			}
			else if(arg is TextBlock)
			{
				var block:TextBlock = TextBlock(arg);
				tl = block.firstLine;
				rect = tl.getBounds(tl.parent);
				var tc:ITextContainer = engine.layout.getContainerForLine(tl);
				
				while(tl)
				{
					if(tc != engine.layout.getContainerForLine(tl))
					{
						rectToContainer[rect] = assureLayerExists(container, layer);
					}
					
					rect = rect.union(tl.getBounds(tl.parent));
					tc = engine.layout.getContainerForLine(tl);
					tl = tl.nextLine;
				}
			}
			else 
			{
				if (arg is TextLine)
				{
					tl = TextLine(arg);
					bounds.push(tl.getBounds(tl.parent));
				}
				else if (arg is Rectangle)
				{
					bounds.push(arg);
				}
				else if (arg is Vector.<Rectangle>)
				{
					bounds = bounds.concat(arg);
				}
				
				var sprite:Sprite = assureLayerExists(container, layer);
				for each(rect in bounds)
				{
					rectToContainer[rect] = sprite;
				}
			}
			
			return bounds;
		}
		
		public function draw(bounds:Vector.<Rectangle>):void
		{
		}
		
		public function destroy():void
		{
			_container = null;
			_engine = null;
			rectToContainer = null;
		}
		
		protected function assureLayerExists(container:ITextContainer, layer:int):Sprite
		{
			var shapes:Sprite = foreground ? container.foreground : container.background;
			while(shapes.numChildren < (layer + 1))
			{
				shapes.addChild(new Sprite());
			}
			
			return Sprite(shapes.getChildAt(shapes.numChildren - layer - 1));
		}
		
		protected function rectToLayer(rect:Rectangle):Sprite
		{
			return rectToContainer[rect] || container.foreground;
		}
    }
}

