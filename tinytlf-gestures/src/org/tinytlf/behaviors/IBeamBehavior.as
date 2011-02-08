/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.behaviors
{
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	
	public class IBeamBehavior extends MultiGestureBehavior
	{
		[Event("rollOver")]
		[Event("mouseOver")]
		[Event("mouseMove")]
		public function setIBeam():void
		{
			if(mirrorRegion)
				return;
			
			Mouse.cursor = MouseCursor.IBEAM;
		}
		
		[Event("rollOut")]
		public function setAuto():void
		{
			Mouse.cursor = MouseCursor.AUTO;
		}
	}
}