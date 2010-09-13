package org.tinytlf.decor.decorations
{
	import flash.display.Graphics;
	import flash.geom.Rectangle;
	
	import org.tinytlf.decor.TextDecoration;
	
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
			
			while(copy.length)
			{
				rect = copy.pop();
				g = rectToLayer(rect).graphics;
				
				g.beginFill(getStyle('bulletColor') || getStyle('fontColor') || 0x00,
					getStyle('bulletAlpha') || getStyle('fontAlpha') || 1);
				
				g.drawCircle(rect.x + (rect.width - diameter), rect.y + (diameter * 2), diameter * .5);
				g.endFill();
			}
		}
	}
}