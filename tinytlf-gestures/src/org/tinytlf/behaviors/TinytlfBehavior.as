package org.tinytlf.behaviors
{
	import flash.events.Event;
	import flash.text.engine.*;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.interaction.EventLineInfo;
	import org.tinytlf.layout.ITextContainer;

	public class TinytlfBehavior extends Behavior
	{
		protected var engine:ITextEngine;
		protected var line:TextLine;
		protected var container:ITextContainer;
		protected var contentElement:ContentElement;
		protected var mirrorRegion:TextLineMirrorRegion;
		
		override protected function act(events:Vector.<Event>):void
		{
			super.act(events);
			
			const info:EventLineInfo = EventLineInfo.getInfo(finalEvent);
			
			if(!info)
				return;
			
			engine = info.engine;
			line = info.line;
			container = info.container;
			mirrorRegion = info.mirrorRegion;
			contentElement = info.element;
		}
	}
}