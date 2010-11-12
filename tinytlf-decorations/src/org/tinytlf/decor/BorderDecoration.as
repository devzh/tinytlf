package org.tinytlf.decor
{
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import org.tinytlf.decor.BackgroundColorDecoration;
	
	public class BorderDecoration extends BackgroundColorDecoration
	{
		public function BorderDecoration(styleObject:Object=null)
		{
			super(styleObject);
		}
		
		override public function draw(bounds:Vector.<Rectangle>):void
		{
			var rect:Rectangle;
			var g:Graphics;
			var copy:Vector.<Rectangle> = bounds.concat();
			var layer:Sprite;
			
			while(copy.length > 0)
			{
				rect = copy.pop();
				
				layer = rectToLayer(rect);
				if(!layer)
					continue;
				
				g = layer.graphics;
				g.lineStyle(
					getStyle("thickness") || 1,
					getStyle("color") || 0x00,
					getStyle("alpha") || 1,
					getStyle("pixelHinting") || false,
					getStyle("scaleMode") || "normal",
					getStyle("caps") || null,
					getStyle("joints") || null,
					getStyle("miterLimit") || 3);
				
				g.beginFill(0x00, 0);
				g.drawRect(rect.x, rect.y, rect.width, rect.height);
				g.lineStyle();
				g.endFill();
			}
		}
	}
}