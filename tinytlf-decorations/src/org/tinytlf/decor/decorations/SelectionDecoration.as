/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.decor.decorations
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import org.tinytlf.decor.TextDecoration;
	
	public class SelectionDecoration extends TextDecoration
	{
		public function SelectionDecoration(styleObject:Object = null)
		{
			super(styleObject);
		}
		
		override public function draw(bounds:Vector.<Rectangle>):void
		{
			super.draw(bounds);
			
			var rect:Rectangle;
			var copy:Vector.<Rectangle> = bounds.concat();
			var g:Graphics;
			var color:uint;
			var alpha:Number;
			var layer:Sprite;
			
			while (copy.length > 0)
			{
				rect = copy.pop();
				
				layer = rectToLayer(rect);
				if(!layer)
					continue;
				
				g = layer.graphics;
				
				color = uint(getStyle("selectionColor"));
				alpha = Number(getStyle("selectionAlpha"));
				
				g.beginFill(color || 0x000000, isNaN(alpha) ? 1 : alpha);
				g.drawRect(rect.x, rect.y, rect.width, rect.height);
				g.endFill();
			}
		}
	}
}

