package org.tinytlf.display.feathers
{
	import feathers.core.FeathersControl;
	
	public class FeathersDocument extends FeathersControl
	{
		public function FeathersDocument()
		{
			super();
		}
		
		include '../documentMixin.as';
		
		override protected function draw():void {
			super.draw();
			
			if(htmlChanged) {
			}
		}
	}
}