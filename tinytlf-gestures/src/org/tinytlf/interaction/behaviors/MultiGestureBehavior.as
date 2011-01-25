package org.tinytlf.interaction.behaviors
{
	import flash.events.Event;
	import flash.geom.Point;
	
	import org.tinytlf.util.TinytlfUtil;

	public class MultiGestureBehavior extends Behavior
	{
		public function MultiGestureBehavior()
		{
			super();
			
			attachListeners(this);
		}
		
		public function attachListeners(target:IBehavior):void
		{
			var listeners:XMLList = TinytlfUtil.describeType(this).factory.method.(child('metadata').(@name == 'Event').length());
			
			var methodName:String;
			var type:String;
			var events:XMLList;
			
			for each(var listener:XML in listeners)
			{
				methodName = listener.attribute('name').toString();
				events = listener.metadata.(@name == 'Event');
				for each(var meta:XML in events)
				{
					type = meta.arg.@value.toString();
					types[type] = this[methodName];
				}
			}
		}
		
		protected var selection:Point;
		protected var caret:int;
		
		override protected function act(events:Vector.<Event>):void
		{
			selection = engine.selection.clone();
			caret = engine.caretIndex;
			
			var type:String = event.type;
			if(type in types)
				types[type].length ? types[type](events) : types[type]();
			else
				defaultAction(events);
		}
		
		private const types:Object = {};
		
		protected function defaultAction(events:Vector.<Event>):void
		{
//			trace('default action occurred on ' + this['constructor'].toString());
		}
		
		protected function get validSelection():Boolean
		{
			return selection.x == selection.x && selection.y == selection.y;
		}
	}
}