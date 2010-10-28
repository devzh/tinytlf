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
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.text.engine.ContentElement;
    import flash.text.engine.TextLine;
    import flash.text.engine.TextLineMirrorRegion;
    import flash.text.engine.TextLineValidity;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.layout.ITextContainer;
    import org.tinytlf.util.TinytlfUtil;
    import org.tinytlf.util.fte.TextLineUtil;

    public class EventLineInfo
    {
        public static function getInfo(event:Event, eventMirror:EventDispatcher = null):EventLineInfo
        {
            var line:TextLine = (event.target as TextLine) || (event.currentTarget as TextLine);
			
            if(line == null)
                return null;
            
			//If the line validity isn't VALID, these calls will throw errors, 
			//so return null.
            if(line.validity == TextLineValidity.INVALID)
                return null;
            
            var engine:ITextEngine = ITextEngine(line.userData);
            var index:int = TinytlfUtil.blockIndexToGlobalIndex(engine, line.textBlock, line.textBlockBeginIndex);
			
            if(event is MouseEvent)
			{
                index = TinytlfUtil.atomIndexToGlobalIndex(engine, line, 
					TextLineUtil.getAtomIndexAtPoint(line, new Point(event['stageX'], event['stageY'])));
			}
            
            var element:ContentElement = TinytlfUtil.globalIndexToContentElement(engine, index);
            var mirrorRegion:TextLineMirrorRegion;
			
			if(line.mirrorRegions)
			{
				mirrorRegion = line.getMirrorRegion(eventMirror || element.eventMirror);
			}
            
            return new EventLineInfo(
                line, 
                engine, 
                mirrorRegion, 
                mirrorRegion == null ? element : mirrorRegion.element,
                event
            );
        }
        
        public function EventLineInfo(line:TextLine, engine:ITextEngine, 
									  mirrorRegion:TextLineMirrorRegion, element:ContentElement, event:Event)
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

