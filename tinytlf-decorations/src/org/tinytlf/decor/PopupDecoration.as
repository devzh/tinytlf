package org.tinytlf.decor
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	[Style(name="component", type="Object")]
	
	public class PopupDecoration extends TextDecoration
	{
		public function PopupDecoration(styleObject:Object = null)
		{
			super(styleObject);
		}
		
		override public function draw(bounds:Vector.<Rectangle>):void
		{
			var component:DisplayObject = (getStyle('component') as DisplayObject);
			if(!component)
				return;
			
			var r:Rectangle = bounds[0];
			var layer:Sprite = rectToLayer(r);
			
			if(!layer.contains(component))
				layer.addChild(component);
			
			component.x = r.x;
			component.y = r.y;
			
			//Pass along any styles that may also be public attributes of the component.
			applyTo(component);
		}
	}
}