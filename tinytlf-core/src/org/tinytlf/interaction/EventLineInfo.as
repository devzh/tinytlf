/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.interaction
{
    import flash.display.Sprite;
    import flash.events.*;
    import flash.text.engine.*;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.layout.ITextContainer;

	// This code is entirely too clever to be proud of it.
	// Seriously, I'm a fucking douche.
    public class EventLineInfo
	{
		private static function eventFilter(event:Event):Function
		{
			return (event is MouseEvent) ? mouseTargetFilter : genericTargetFilter;
		}
		
		private static function mouseTargetFilter(target:*):Info
		{
			if(target is ITextContainer)
				return new MouseContainerInfo();
			if(target is TextLine)
				return new MouseLineInfo();
			if(target is Sprite)
				return new MouseSpriteInfo();
			
			return new NullInfo();
		}
		
		private static function genericTargetFilter(target:*):Info
		{
			if(target is ITextContainer)
				return new GenericContainerInfo();
			if(target is TextLine)
				return new GenericLineInfo();
			if(target is Sprite)
				return new GenericSpriteInfo();
			
			return new NullInfo();
		}
		
        public static function getInfo(event:Event):EventLineInfo
        {
			return	Info(eventFilter(event).call(null, event.target))
					.getInfo(event, event.target)
					||
					Info(eventFilter(event).call(null, event.currentTarget))
					.getInfo(event, event.currentTarget);
        }
        
        public function EventLineInfo(line:TextLine, engine:ITextEngine, 
									  mirrorRegion:TextLineMirrorRegion, element:ContentElement)
        {
            _engine = engine;
            _element = element;
            _line = line;
            _mirrorRegion = mirrorRegion;
            _container = engine.layout.getContainerForLine(line);
        }
        
        private var _container:ITextContainer;
        public function get container():ITextContainer
        {
            return _container;
        }
        
        private var _engine:ITextEngine;
        public function get engine():ITextEngine
        {
            return _engine;
        }
        
        private var _element:ContentElement;
        public function get element():ContentElement
        {
            return _element;
        }
        
        private var _line:TextLine;
        public function get line():TextLine
        {
            return _line;
        }
        
        private var _mirrorRegion:TextLineMirrorRegion;
        public function get mirrorRegion():TextLineMirrorRegion
        {
            return _mirrorRegion;
        }
    }
}
import flash.display.*;
import flash.events.*;
import flash.geom.*;
import flash.text.engine.*;

import org.tinytlf.*;
import org.tinytlf.interaction.EventLineInfo;
import org.tinytlf.layout.ITextContainer;
import org.tinytlf.util.TinytlfUtil;
import org.tinytlf.util.fte.TextLineUtil;

internal interface Info
{
	function getInfo(event:Event, target:*):EventLineInfo;
}

internal class NullInfo implements Info
{
	public function getInfo(event:Event, target:*):EventLineInfo
	{
		return new EventLineInfo(null, null, null, null);
	}
}

internal class MouseContainerInfo implements Info
{
	public function getInfo(event:Event, target:*):EventLineInfo
	{
		var m:MouseEvent = MouseEvent(event);
		var c:ITextContainer = ITextContainer(target);
		var engine:ITextEngine = c.engine;
		var p:Point = new Point(m.stageX, m.stageY);
		
		var globalIndex:int = TinytlfUtil.pointToGlobalIndex(engine, p);
		var line:TextLine = TinytlfUtil.globalIndexToTextLine(engine, globalIndex);
		var atomIndex:int = TextLineUtil.getAtomIndexAtPoint(line, p)
		var element:ContentElement = TextLineUtil.getElementAtAtomIndex(line, atomIndex);
		var mirrorRegion:TextLineMirrorRegion = TextLineUtil.getMirrorRegionForElement(line, element);
		
		return new EventLineInfo(line, engine, mirrorRegion, element);
	}
}

internal class GenericContainerInfo implements Info
{
	public function getInfo(event:Event, target:*):EventLineInfo
	{
		var c:ITextContainer = ITextContainer(target);
		var engine:ITextEngine = c.engine;
		
		var globalIndex:int = engine.caretIndex;
		
		var line:TextLine = TinytlfUtil.globalIndexToTextLine(engine, globalIndex);
		var atomIndex:int = TinytlfUtil.globalIndexToAtomIndex(engine, line, engine.caretIndex);
		var element:ContentElement = TextLineUtil.getElementAtAtomIndex(line, atomIndex);
		var mirrorRegion:TextLineMirrorRegion = TextLineUtil.getMirrorRegionForElement(line, element);
		
		return new EventLineInfo(line, engine, mirrorRegion, element);
	}
}

internal class MouseLineInfo implements Info
{
	public function getInfo(event:Event, target:*):EventLineInfo
	{
		var line:TextLine = TextLine(target);
		
		if(line.validity != TextLineValidity.VALID)
		{
			trace('error: TextLine validity was ' + line.validity);
			return null;
		}
		
		var engine:ITextEngine = line.userData as ITextEngine;
		var block:TextBlock = line.textBlock;
		var atomIndex:int = 0;
		var m:MouseEvent = MouseEvent(event);
		
		atomIndex = TextLineUtil.getAtomIndexAtPoint(line, new Point(m.stageX, m.stageY));
		var element:ContentElement = TextLineUtil.getElementAtAtomIndex(line, atomIndex);
		var mirrorRegion:TextLineMirrorRegion = TextLineUtil.getMirrorRegionForElement(line, element);
		
		return new EventLineInfo(line, engine, mirrorRegion, element);
	}
}

internal class GenericLineInfo implements Info
{
	public function getInfo(event:Event, target:*):EventLineInfo
	{
		var line:TextLine = TextLine(target);
		
		if(line.validity != TextLineValidity.VALID)
		{
			trace('error: TextLine validity was ' + line.validity);
			return null;
		}
		
		var engine:ITextEngine = line.userData as ITextEngine;
		var block:TextBlock = line.textBlock;
		var atomIndex:int = 0;
		
		atomIndex = TinytlfUtil.globalIndexToAtomIndex(engine, line, engine.caretIndex);
		var element:ContentElement = TextLineUtil.getElementAtAtomIndex(line, atomIndex);
		var mirrorRegion:TextLineMirrorRegion = TextLineUtil.getMirrorRegionForElement(line, element);
		
		return new EventLineInfo(line, engine, mirrorRegion, element);
	}
}

internal class MouseSpriteInfo implements Info
{
	public function getInfo(event:Event, target:*):EventLineInfo
	{
		var m:MouseEvent = event as MouseEvent;
		var sprite:Sprite = Sprite(target);
		
		var objs:Array = sprite.getObjectsUnderPoint(new Point(m.localX, m.localY));
		
		var line:TextLine;
		
		while(line == null && objs.length)
			line = objs.shift() as TextLine;
		
		if(!line)
			return null;
		
		return event is MouseEvent ? 
			new MouseLineInfo().getInfo(event, line) : 
			new GenericLineInfo().getInfo(event, line);
	}
}

internal class GenericSpriteInfo implements Info
{
	public function getInfo(event:Event, target:*):EventLineInfo
	{
		throw new Error("How am I supposed to know which line to select when all " +
			"you give me is a Sprite with no coordinates?");
	}
}