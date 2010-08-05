package org.tinytlf.interaction.gestures.mouse
{
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.events.MouseEvent;

    import org.tinytlf.interaction.gestures.Gesture;
    import org.tinytlf.interaction.gestures.GestureEvent;

    [Event("mouseOut")]
    [Event("rollOut")]

    public class MouseOutGesture extends Gesture
    {
        public function MouseOutGesture(target:IEventDispatcher = null)
        {
            super(target);

            hsm.appendChild(<out/>);
        }

        public function out(event:MouseEvent):Boolean
        {
            return event.type == MouseEvent.MOUSE_OUT ||
                    event.type == MouseEvent.ROLL_OUT;
        }
    }
}