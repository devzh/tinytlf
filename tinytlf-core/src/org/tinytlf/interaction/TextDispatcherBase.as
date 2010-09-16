/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.interaction
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	/**
	 * <p>
	 * <code>TextDispatcherBase</code> is a convenient base class for classes
	 * which handle interactive capabilities in tinytlf. It's especially 
	 * convenient to subclass for eventMirrors for FTE 
	 * <code>ContentElements</code>.
	 * </p>
	 * <p>
	 * <code>TextDispatcherBase</code> keeps track of the mouse states and
	 * coordinates.
	 * </p>
	 */
	public class TextDispatcherBase extends EventDispatcher
	{
		public function TextDispatcherBase(target:IEventDispatcher = null)
		{
			super(target);
			
			addListeners(this);
		}
		
		public static const UP:uint = 0x1;
		public static const OVER:uint = 0x2;
		public static const DOWN:uint = 0x4;
		
		protected var mouseState:uint = UP;
		protected var mouseCoords:Point;
		
		protected function onClick(event:MouseEvent):void
		{
			mouseState &= ~DOWN;
			mouseState |= UP;
			mouseCoords = new Point(event.stageX, event.stageY);
		}
		
		protected function onDoubleClick(event:MouseEvent):void
		{
			mouseState &= ~DOWN;
			mouseState |= UP;
			mouseCoords = new Point(event.stageX, event.stageY);
		}
		
		protected function onRollOver(event:MouseEvent):void
		{
			mouseState |= OVER;
			mouseCoords = new Point(event.stageX, event.stageY);
		}
		
		protected function onRollOut(event:MouseEvent):void
		{
			mouseState &= ~OVER;
			mouseState &= ~DOWN;
			mouseCoords = new Point(event.stageX, event.stageY);
		}
		
		protected function onMouseMove(event:MouseEvent):void
		{
			mouseState |= OVER;
			mouseCoords = new Point(event.stageX, event.stageY);
		}
		
		protected function onMouseDown(event:MouseEvent):void
		{
			mouseState |= DOWN;
			mouseState &= ~UP;
			mouseCoords = new Point(event.stageX, event.stageY);
		}
		
		protected function onMouseUp(event:MouseEvent):void
		{
			mouseState &= ~DOWN;
			mouseState |= UP;
			mouseCoords = new Point(event.stageX, event.stageY);
		}
		
		protected function onKeyDown(event:KeyboardEvent):void
		{
		}
		
		protected function onKeyUp(event:KeyboardEvent):void
		{
		}
		
		protected function onCopy(event:Event):void
		{
		}
		
		protected function onPaste(event:Event):void
		{
		}
		
		protected function onCut(event:Event):void
		{
		}
		
		protected function onSelectAll(event:Event):void
		{
		}
		
		public function addListeners(target:IEventDispatcher):void
		{
			target.addEventListener(MouseEvent.MOUSE_OVER, onRollOver, false, 0, true);
			target.addEventListener(MouseEvent.MOUSE_OUT, onRollOut, false, 0, true);
			
			target.addEventListener(MouseEvent.ROLL_OVER, onRollOver, false, 0, true);
			target.addEventListener(MouseEvent.ROLL_OUT, onRollOut, false, 0, true);
			
			target.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove, false, 0, true);
			target.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false, 0, true);
			target.addEventListener(MouseEvent.MOUSE_UP, onMouseUp, false, 0, true);
			target.addEventListener(MouseEvent.CLICK, onClick, false, 0, true);
			target.addEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick, false, 0, true);
			
			target.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
			target.addEventListener(KeyboardEvent.KEY_UP, onKeyUp, false, 0, true);
			
			target.addEventListener(Event.COPY, onCopy, false, 0, true);
			target.addEventListener(Event.PASTE, onPaste, false, 0, true);
			target.addEventListener(Event.CUT, onCut, false, 0, true);
			target.addEventListener(Event.SELECT_ALL, onSelectAll, false, 0, true);
		}
		
		public function removeListeners(target:IEventDispatcher):void
		{
			target.removeEventListener(MouseEvent.MOUSE_OVER, onRollOver);
			target.removeEventListener(MouseEvent.MOUSE_OUT, onRollOut);
			
			target.removeEventListener(MouseEvent.ROLL_OVER, onRollOver);
			target.removeEventListener(MouseEvent.ROLL_OUT, onRollOut);
			
			target.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			target.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			target.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			target.removeEventListener(MouseEvent.CLICK, onClick);
			target.removeEventListener(MouseEvent.DOUBLE_CLICK, onDoubleClick);
			
			target.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			target.removeEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			target.removeEventListener(Event.COPY, onCopy);
			target.removeEventListener(Event.PASTE, onPaste);
			target.removeEventListener(Event.CUT, onCut);
			target.removeEventListener(Event.SELECT_ALL, onSelectAll);
		}
		
		protected var eventTime:int = 0;
		
		protected function allowEvent(checkTime:Number = 100):Boolean
		{
			var time:int = getTimer();
			var ret:Boolean = (time - eventTime) > checkTime;
			eventTime = time;
			return ret;
		}
	}
}

