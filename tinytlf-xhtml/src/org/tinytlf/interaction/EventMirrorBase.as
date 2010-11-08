/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.interaction
{
	import flash.events.*;
	import flash.text.engine.ContentElement;
	import flash.text.engine.TextLine;
	import flash.utils.*;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.util.TinytlfUtil;
	
	/**
	 * <code>EventMirrorBase</code> is a nice base class for classes which 
	 * handle TLMR-based interaction in tinytlf.
	 */
	public class EventMirrorBase extends EventDispatcher
	{
		public function EventMirrorBase(target:IEventDispatcher = null)
		{
			super(target);
			
			attachListeners(this);
		}
		
		public function attachListeners(target:IEventDispatcher):void
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
					target.addEventListener(type, this[methodName], false, 0, true);
				}
			}
		}
		
		protected const listeners:Object = {};
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void
		{
			super.addEventListener(type, execute, useCapture, priority, useWeakReference);
			
			listeners[type] = listener;
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void
		{
			super.removeEventListener(type, listener, useCapture);
			
			if(listeners.hasOwnProperty(type))
				delete listeners[type];
		}
		
		protected var info:EventLineInfo;
		protected var line:TextLine;
		protected var content:ContentElement;
		protected var engine:ITextEngine;
		protected var event:Event;
		
		protected final function execute(event:Event):void
		{
			var type:String = event.type;
			
			if(type in blockedEvents && blockedEvents[type] == true)
			{
				delete blockedEvents[type];
				return;
			}
			
			info = EventLineInfo.getInfo(event, this);
			if(!info)
				return;
			
			engine = info.engine;
			line = info.line;
			content = info.element;
			this.event = event;
			
			if(type in listeners)
			{
				var func:Function = listeners[type];
				func.length ? func(event) : func();
			}
			
			event = null;
		}
		
		private var blockedEvents:Object = {};
		protected final function blockEvent(type:String):void
		{
			blockedEvents[type] = true;
		}
		
		protected final function unblockEvent(type:String):void
		{
			delete blockedEvents[type];
		}
		
		protected final function blockAllEvents():void
		{
			for(var type:String in listeners)
				blockedEvents[type] = true;
		}
		
		protected final function unblockAllEvents():void
		{
			blockedEvents = {};
		}
		
		public function destroy():void
		{
			engine = null;
			line = null;
			content = null;
			event = null;
			blockedEvents = null;
			for(var type:String in listeners)
			{
				removeEventListener(type, execute);
				delete listeners[type];
			}
		}
	}
}

