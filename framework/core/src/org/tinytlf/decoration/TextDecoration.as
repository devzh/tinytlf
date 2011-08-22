package org.tinytlf.decoration
{
	import flash.geom.Rectangle;
	
	import org.tinytlf.Styleable;
	
	public class TextDecoration extends Styleable implements ITextDecoration
	{
		public function TextDecoration(styleObject:Object = null)
		{
			super(styleObject);
		}
		
		public function set foreground(value:Boolean):void
		{
		}
		
		public function setup(layer:int = 3, ... args):Vector.<Rectangle>
		{
			return null;
		}
		
		public function draw(bounds:Vector.<Rectangle>):void
		{
		}
		
		public function destroy():void
		{
		}
	}
}