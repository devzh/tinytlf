/*
* Copyright (c) 2010 the original author or authors
*
* Permission is hereby granted to use, modify, and distribute this file
* in accordance with the terms of the license agreement accompanying it.
*/
package org.tinytlf.behaviors
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	
	
	public class FocusBehavior extends MultiGestureBehavior
	{
		[Event("keyDown")]
		[Event("mouseDown")]
		[Event("mouseMove")]
		[Event("click")]
		[Event("doubleClick")]
		public function setFocus():void
		{
			line.stage.focus = container.target;
		}
	}
}