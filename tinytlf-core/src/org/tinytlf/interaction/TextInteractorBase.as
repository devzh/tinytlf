/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.interaction
{
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.interaction.TextDispatcherBase;
    
    public class TextInteractorBase extends TextDispatcherBase implements ITextInteractor
    {
        protected var _engine:ITextEngine;
        public function get engine():ITextEngine
        {
            return _engine;
        }
        
        public function set engine(textEngine:ITextEngine):void
        {
            if(textEngine == _engine)
                return;
            
            _engine = textEngine;
        }
        
        private var mirrorMap:Dictionary = new Dictionary(true);
		
        public function mapMirror(element:*, mirrorClassOrFactory:Object):void
        {
            mirrorMap[element] = mirrorClassOrFactory;
        }
        
        public function unMapMirror(element:*):Boolean
        {
            if(element in mirrorMap)
                return delete mirrorMap[element];
            
            return false;
        }
        
        public function hasMirror(element:*):Boolean
        {
            return Boolean(element in mirrorMap);
        }
        
        public function getMirror(element:* = null):EventDispatcher
        {
            var mirror:Object = mirrorMap[element];
            
            if(mirror is Class)
                return new(mirror as Class)() as EventDispatcher;
            
            if(mirror is Function)
                return (mirror as Function)() as EventDispatcher;
            
            return null;
        }
    }
}

