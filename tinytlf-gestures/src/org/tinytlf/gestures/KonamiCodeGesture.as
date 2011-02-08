package org.tinytlf.gestures
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	
	[Event("keyUp")]
	public class KonamiCodeGesture extends Gesture
	{
		public function KonamiCodeGesture()
		{
			super();
			
			hsm.appendChild(
				<up>
					<up2>
						<down>
							<down2>
								<left>
									<right>
										<left2>
											<right2>
												<b>
													<a>
														<enter/>
													</a>
												</b>
											</right2>
										</left2>
									</right>
								</left>
							</down2>
						</down>
					</up2>
				</up>
				);
		}
		
		public function up(e:KeyboardEvent):Boolean
		{
			return e.keyCode === Keyboard.UP;
		}
		
		public function up2(e:KeyboardEvent):Boolean
		{
			return up(e);
		}
		
		public function down(e:KeyboardEvent):Boolean
		{
			return e.keyCode === Keyboard.DOWN;
		}
		
		public function down2(e:KeyboardEvent):Boolean
		{
			return down(e);
		}
		
		public function left(e:KeyboardEvent):Boolean
		{
			return e.keyCode == Keyboard.LEFT;
		}
		
		public function left2(e:KeyboardEvent):Boolean
		{
			return left(e);
		}
		
		public function right(e:KeyboardEvent):Boolean
		{
			return e.keyCode == Keyboard.RIGHT;
		}
		
		public function right2(e:KeyboardEvent):Boolean
		{
			return right(e);
		}
		
		public function b(e:KeyboardEvent):Boolean
		{
			return String.fromCharCode(e.charCode) === 'b';
		}
		
		public function a(e:KeyboardEvent):Boolean
		{
			return String.fromCharCode(e.charCode) === 'a';
		}
		
		public function enter(e:KeyboardEvent):Boolean
		{
			return e.keyCode == Keyboard.ENTER;
		}
	}
}