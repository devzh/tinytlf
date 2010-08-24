package org.tinytlf.interaction.gestures.keyboard
{
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import org.tinytlf.interaction.gestures.Gesture;
	
	[Event("keyUp")]
	public class KonamiCodeGesture extends Gesture
	{
		public function KonamiCodeGesture(target:IEventDispatcher=null)
		{
			super(target);
			
			hsm.appendChild(<up><up><down><down><left><right><left><right><b><a>
<enter/></a></b></right></left></right></left></down></down></up></up>);
		}
		
		public function up(e:KeyboardEvent):Boolean
		{
			return e.keyCode === Keyboard.UP;
		}
		
		public function down(e:KeyboardEvent):Boolean
		{
			return e.keyCode === Keyboard.DOWN;
		}
		
		public function left(e:KeyboardEvent):Boolean
		{
			return e.keyCode == Keyboard.LEFT;
		}
		
		public function right(e:KeyboardEvent):Boolean
		{
			return e.keyCode == Keyboard.RIGHT;
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