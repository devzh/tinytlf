package org.tinytlf.interaction.gestures
{
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	
	
	[Event("mouseDown")]
	[Event("mouseUp")]
	[Event("mouseMove")]
	
	public class MouseDoubleDownGesture extends Gesture
	{
		public function MouseDoubleDownGesture()
		{
			super();
			
			hsm.appendChild(
				<down>
					<up>
						<down2/>
					</up>
				</down>);
			
			hsm.appendChild(<drag/>);
		}
		
		public function drag(event:MouseEvent):Boolean
		{
			go = go && event.buttonDown;
			return go && event.type == MouseEvent.MOUSE_MOVE;
		}
		
		public function down(event:MouseEvent):Boolean
		{
			return event.type == MouseEvent.MOUSE_DOWN;
		}
		
		private var go:Boolean = false;
		
		public function down2(event:MouseEvent):Boolean
		{
			go = (getTimer() - upTime) < 400;
			
			return go && event.type == MouseEvent.MOUSE_DOWN;
		}
		
		private var upTime:int = 0;
		
		public function up(event:MouseEvent):Boolean
		{
			upTime = getTimer();
			return event.type == MouseEvent.MOUSE_UP;
		}
		
		override protected function testNotifiable(state:XML):Boolean
		{
			var result:Boolean = super.testNotifiable(state);
			
			if(!result)
				return false;
			
			result = go;
			
			return result;
		}
	}
}