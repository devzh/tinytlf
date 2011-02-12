package org.tinytlf.gestures
{
	import flash.events.MouseEvent;
	import flash.utils.getTimer;
	
	
	[Event("mouseDown")]
	[Event("mouseUp")]
	[Event("mouseMove")]
	
	public class MouseTripleDownGesture extends Gesture
	{
		public function MouseTripleDownGesture()
		{
			super();
			
			hsm.appendChild(
				<down>
					<up>
						<down>
							<up>
								<down3/>
							</up>
						</down>
					</up>
				</down>);
			hsm.appendChild(<drag/>);
		}
		
		public function drag(event:MouseEvent):Boolean
		{
			return go && event.buttonDown && event.type == MouseEvent.MOUSE_MOVE;
		}
		
		public function down(event:MouseEvent):Boolean
		{
			return event.type == MouseEvent.MOUSE_DOWN;
		}
		
		private var go:Boolean = false;
		
		public function down3(event:MouseEvent):Boolean
		{
			go = (getTimer() - upTime) < 500;
			upTime = 0;
			
			resetStates();
			
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
			return super.testNotifiable(state) && go;
		}
	}
}