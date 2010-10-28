package org.tinytlf.components.cs4
{
	import flash.geom.Transform;
	
	import org.tinytlf.components.TextField;
	
	public class FlashTextField extends TextField
	{
		public function FlashTextField()
		{
			super();
			
//			if($width > 0)
//			{
//				width = $width;
//				$width = 100;
//			}
//			if($height > 0)
//			{
//				height = $height;
//				$height = 100;
//			}
			
			removeChildAt(0);
			graphics.clear();
		}
		
		public function setSize(w:Number, h:Number):void
		{
			width = w;
			height = h;
			draw();
		}
		
		public function draw():void
		{
			engine.invalidate();
			engine.render();
		}
	}
}
