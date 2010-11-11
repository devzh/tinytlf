package org.tinytlf.decor
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	
	public class BulletDecoration extends TextDecoration
	{
		public function BulletDecoration(styleObject:Object = null)
		{
			super(styleObject);
		}
		
		override public function draw(bounds:Vector.<Rectangle>):void
		{
			var copy:Vector.<Rectangle> = bounds.concat();
			var rect:Rectangle;
			var g:Graphics;
			var diameter:Number = getStyle('diameter') || 4;
			var layer:Sprite;
			
			while(copy.length)
			{
				rect = copy.pop();
				
				layer = rectToLayer(rect);
				if(!layer)
					continue;
				
				g = layer.graphics;
				
				g.beginFill(getStyle('bulletColor') || getStyle('fontColor') || 0x00,
					getStyle('bulletAlpha') || getStyle('fontAlpha') || 1);
				
				g.drawCircle(rect.x + (rect.width - diameter), rect.y + (diameter * 2), diameter * .5);
				g.endFill();
			}
		}
	}
}