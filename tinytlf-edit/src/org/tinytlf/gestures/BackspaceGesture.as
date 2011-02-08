package org.tinytlf.gestures
{
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;
    

    [Event("keyDown")]

    public class BackspaceGesture extends Gesture
    {
        public function BackspaceGesture()
        {
			super();
			
            hsm.appendChild(<backspace/>);
        }

        public function backspace(event:KeyboardEvent):Boolean
        {
            return event.keyCode == Keyboard.BACKSPACE;
        }
    }
}