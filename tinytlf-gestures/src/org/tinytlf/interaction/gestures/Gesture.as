package org.tinytlf.interaction.gestures
{
	import flash.events.*;
	import flash.utils.*;
	
	import org.tinytlf.util.TinytlfUtil;
	import org.tinytlf.interaction.behaviors.IBehavior;
	
	public class Gesture extends EventDispatcher implements IGesture
	{
		public function hearken(target:IEventDispatcher):void
		{
			var events:XMLList = TinytlfUtil.describeType(this).factory.metadata.(@name == 'Event');
			var type:String;
			for each(var event:XML in events)
			{
				type = event.arg.@value.toString();
				target.addEventListener(type, execute, false, 0, true);
			}
			resetStates();
		}
		
		public function spurn(target:IEventDispatcher):void
		{
			var events:XMLList = TinytlfUtil.describeType(this).factory.metadata.(@name == 'Event');
			var type:String;
			for each(var event:XML in events)
			{
				type = event.arg.@value.toString();
				target.removeEventListener(type, execute);
			}
			resetStates();
		}
		
		protected var behaviors:Vector.<IBehavior> = new Vector.<IBehavior>();
		
		public function addBehavior(behavior:IBehavior):void
		{
			if(behaviors.indexOf(behavior) == -1)
				behaviors.push(behavior);
		}
		
		public function removeBehavior(behavior:IBehavior):void
		{
			var i:int = behaviors.indexOf(behavior);
			if(i != -1)
				behaviors.splice(i, 1);
		}
		
		protected var hsm:XML = <_/>;
		protected var states:XMLList = <>{hsm}</>;
		protected var events:Vector.<Event> = new <Event>[];
		
		////
		// Everything after this point is basically magic. It was written during
		// one coffee fueled weekend, and to be honest, I don't remember much of
		// it. That night is just a blur in my memory. Modify at your own peril.
		//
		// Here be dragons.
		// (I've always felt that any serious library needs this comment at 
		// least once).
		////
		
		protected function execute(event:Event):void
		{
			var childStates:XMLList = getChildStates();
			
			resetStates();
			
			var func:Function;
			var result:Boolean = false;
			var name:String;
			
			for each(var childState:XML in childStates)
			{
				name = childState.localName();
				
				if(states.contains(childState) || !name)
					continue;
				
				if(!(name in this) || !(this[name] is Function))
				{
					throw new Error('Gesture ' + this['constructor'].toString() +
									' with state "' + name + '"' +
									' is missing the matching filter method.');
				}
				
				func = (this[name] as Function);
				
				try{
					result = func(event);
				}catch(e:Error){
					result = false;
				}
				
				if(!result)
					continue;
				
				//Hang onto this event (until we notify the behaviors).
				events.push(event);
				
				if(testNotifiable(childState))
				{
					notifyBehaviors(events);
					//Clear out the events list (don't want memory leaks!)
					events.length = 0;
				}
				
				states += childState;
			}
		}
		
		protected function resetStates():void
		{
			states = <>{hsm}</>;
		}
		
		protected function getChildStates():XMLList
		{
			var childStates:XMLList = states.*.(nodeKind() != 'text');
			var namedStates:XMLList = hsm..*.(attribute('id').length());
			
			for each(var childStateID:String in states.@idrefs.toXMLString().split(/\s+/))
				if(childStateID)
					childStates += namedStates.(@id == childStateID);
			
			return childStates;
		}
		
		protected function testNotifiable(state:XML):Boolean
		{
			return (state.@idrefs.toString() == "" || state.@idrefs == "*") && (state.*.length() == 0);
		}
		
		////
		// This isn't magic. I understand this part.
		////
		
		protected function notifyBehaviors(events:Vector.<Event>):void
		{
			for each(var behavior:IBehavior in behaviors)
			{
				behavior.execute(events);
			}
		}
	}
}