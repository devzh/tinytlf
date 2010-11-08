package org.tinytlf.interaction.behaviors
{
    import flash.events.Event;
    import flash.text.engine.TextLine;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.interaction.EventLineInfo;

    public class Behavior implements IBehavior
    {
		final public function execute(events:Vector.<Event>):void
		{
			if(events.length <= 0)
				return;
			
			event = events[events.length - 1];
			if(!event)
				return;
			
			info = EventLineInfo.getInfo(event);
			
			if(!info)
				return;
			
			engine = info.engine;
			line = info.line;
			
			act(events);
		}
		
		protected var event:Event;
		protected var info:EventLineInfo;
		protected var engine:ITextEngine;
		protected var line:TextLine;
		
		protected function act(events:Vector.<Event>):void
		{
		}
    }
}