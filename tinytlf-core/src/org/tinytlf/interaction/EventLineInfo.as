/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.interaction
{
    import flash.events.*;
    import flash.geom.Point;
    import flash.text.engine.*;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.analytics.ITextEngineAnalytics;
    import org.tinytlf.layout.ITextContainer;
    import org.tinytlf.util.TinytlfUtil;
    import org.tinytlf.util.fte.TextLineUtil;

    public class EventLineInfo
    {
        public static function getInfo(event:Event, eventMirror:EventDispatcher = null):EventLineInfo
        {
			var container:ITextContainer = event.target as ITextContainer || event.currentTarget as ITextContainer;
            var line:TextLine;
			
			if(container)
			{
				var e:ITextEngine = container.engine;
				
				if(event is MouseEvent)
					line = TinytlfUtil.yToTextLine(e, MouseEvent(event).localY);
				else
					line = TinytlfUtil.globalIndexToTextLine(e, e.caretIndex);
			}
			
            if(line == null)
                return null;
            
			//If the line validity isn't VALID, these calls will throw errors, 
			//so return null.
            if(line.validity == TextLineValidity.INVALID)
                return null;
            
			var block:TextBlock = line.textBlock;
            var engine:ITextEngine = ITextEngine(line.userData);
			var atomIndex:int = 0;
			
            if(event is MouseEvent)
			{
				var m:MouseEvent = event as MouseEvent;
				atomIndex = TextLineUtil.getAtomIndexAtPoint(line, new Point(m.stageX, m.stageY));
			}
			else if(engine.caretIndex)
			{
				var analytics:ITextEngineAnalytics = engine.analytics;
				atomIndex = engine.caretIndex - analytics.blockContentStart(block) - line.textBlockBeginIndex;
			}
			
			var element:ContentElement = TextLineUtil.getElementAtAtomIndex(line, atomIndex);
            var mirrorRegion:TextLineMirrorRegion;
			if(line.mirrorRegions)
			{
				if(eventMirror)
				{
					mirrorRegion = line.getMirrorRegion(eventMirror);
					element = mirrorRegion.element;
				}
				else
				{
					mirrorRegion = TextLineUtil.getMirrorRegionForElement(line, element);
				}
			}
			
            return new EventLineInfo(
                line, 
                engine, 
                mirrorRegion,
				element
			);
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

