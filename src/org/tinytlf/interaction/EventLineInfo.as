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
    import flash.text.engine.ContentElement;
    import flash.text.engine.TextLine;
    import flash.text.engine.TextLineMirrorRegion;
    import flash.text.engine.TextLineValidity;
    import flash.utils.getDefinitionByName;

    import org.tinytlf.ITextEngine;
    import org.tinytlf.layout.ITextContainer;
    import org.tinytlf.utils.FTEUtil;

    public class EventLineInfo
    {
        public static var uiLineClass:Class = checkFlex();
        
        protected static function checkFlex():Class
        {
            try{
                return getDefinitionByName("mx.tinytlf::UITextLine") as Class;
            }
            catch(e:*){
            }
            
            return null;
        }
        
        public static function getInfo(event:Event, eventMirror:EventDispatcher = null):EventLineInfo
        {
            var target:Object = event.target;
            var canProcess:Boolean = (target is TextLine) || (uiLineClass && target is uiLineClass);
            
            if(!canProcess)
                return null;
            
            var line:TextLine = (target as TextLine) || Object(target).line;
            
            if(line.validity == TextLineValidity.INVALID)
                return null;
            
            var index:int = line.textBlockBeginIndex;
            
            if(event is MouseEvent)
                index = FTEUtil.getAtomIndexAtPoint(line, MouseEvent(event).stageX, MouseEvent(event).stageY);
            
            var element:ContentElement = FTEUtil.getContentElementAt(line.textBlock.content, index);
            var mirrorRegion:TextLineMirrorRegion = line.getMirrorRegion(eventMirror || element.eventMirror);
            
            return new EventLineInfo(
                line, 
                line.userData, 
                mirrorRegion, 
                mirrorRegion == null ? element : mirrorRegion.element,
                event
            );
        }
        
        public function EventLineInfo(line:TextLine, engine:ITextEngine, mirrorRegion:TextLineMirrorRegion, element:ContentElement, event:Event)
        {
            _engine = engine;
            _element = element;
            _line = line;
            _mirrorRegion = mirrorRegion;
            _container = engine.layout.getContainerForLine(line);
            _event = event;
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
        
        private var _event:Event;
        public function get event():Event
        {
            return _event;
        }
    }
}

