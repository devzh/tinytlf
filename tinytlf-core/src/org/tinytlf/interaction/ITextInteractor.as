/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.interaction
{
    import flash.events.EventDispatcher;
    import flash.events.IEventDispatcher;
    
    import org.tinytlf.ITextEngine;
    
    public interface ITextInteractor extends IEventDispatcher
    {
        function get engine():ITextEngine;
        function set engine(textEngine:ITextEngine):void;
        
        function hasMirror(element:*):Boolean;
        
        /**
         * Returns an EventDispatcher for an element name. Typically an
         * IModelAdapter calls this when he is creating a ContentElement
         * and is ready to specify an eventMirror.
         */
        function getMirror(element:* = null):EventDispatcher;
        
        /**
         * Maps a mirror class or instance to an elementName.
         * @return True if the mirror was successfully  mapped, False
         * if it wasn't.
         */
        function mapMirror(element:*, mirrorClassOrInstance:Object):void;
        /**
         * Unmaps the mirror class or instance for the given elementName.
         * @return True if the mirror was successfully  unmapped, or False
         * if it wasn't.
         */
        function unMapMirror(element:*):Boolean;
    }
}

