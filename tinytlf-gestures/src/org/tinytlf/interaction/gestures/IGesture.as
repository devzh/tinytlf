package org.tinytlf.interaction.gestures
{
	import flash.events.IEventDispatcher;
	
	import org.tinytlf.interaction.behaviors.IBehavior;
	
	public interface IGesture
	{
		////
		// Nobody's going to read these method names anyway.
		// Might as well make it interesting.
		////
		function hearken(target:IEventDispatcher):void;
		function spurn(target:IEventDispatcher):void;
		
		function addBehavior(behavior:IBehavior):void;
		function removeBehavior(behavior:IBehavior):void;
	}
}