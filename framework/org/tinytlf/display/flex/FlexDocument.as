package org.tinytlf.display.flex
{
	import mx.core.UIComponent;
	
	import spark.core.IViewport;
	
	public class FlexDocument extends UIComponent implements IViewport
	{
		public function FlexDocument()
		{
			super();
		}
		
		include '../documentMixin.as';
		
		override protected function updateDisplayList(w:Number, h:Number):void {
			
			super.updateDisplayList(w, h);
			
			if(htmlChanged) {
				
			}
		}
		
		private var cWidth:Number = 0;
		public function get contentWidth():Number {
			return cWidth;
		}
		
		private var cHeight:Number = 0;
		public function get contentHeight():Number {
			return cHeight;
		}
		
		private var viewportChanged:Boolean = false;
		
		private var hsp:Number = 0;
		public function get horizontalScrollPosition():Number {
			return hsp;
		}
		
		public function set horizontalScrollPosition(value:Number):void {
			if(value == hsp) return;
			
			hsp = value;
			// tryRenderBuffer = (hsp + width >= cWidth);
			viewportChanged = true;
			invalidateDisplayList();
		}
		
		private var vsp:Number = 0;
		public function get verticalScrollPosition():Number {
			return vsp;
		}
		
		public function set verticalScrollPosition(value:Number):void {
			if(value == vsp) return;
			
			vsp = value;
			
			// tryRenderBuffer = (vsp + height >= cHeight);
			viewportChanged = true;
			invalidateDisplayList();
		}
		
		public function getHorizontalScrollPositionDelta(navigationUnit:uint):Number {
			return 10;
		}
		
		public function getVerticalScrollPositionDelta(navigationUnit:uint):Number {
			return 10;
		}
		
		public function get clipAndEnableScrolling():Boolean {
			return true;
		}
		
		public function set clipAndEnableScrolling(value:Boolean):void {}
	}
}