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
    
	/**
	 * <p>
	 * ITextInteractor is the central interaction actor for tinytlf. You can 
	 * externally map element names or types to Classes or Functions which 
	 * return EventDispatcher instances.
	 * </p>
	 * <p>
	 * This map is most commonly called during <code>ContentElement</code> 
	 * creation, from <code>IContentElementFactory</code>s to provide an
	 * <code>eventMirror</code> EventDispatcher to the 
	 * <code>ContentElement</code>.
	 * </p>
	 * 
	 * @see org.tinytlf.layout.model.factories.IContentElementFactory
	 */
    public interface ITextInteractor extends IEventDispatcher
    {
		/**
		 * <p>
		 * Reference to the central <code>ITextEngine</code> facade for this
		 * <code>interactor</code>.
		 * </p>
		 * 
		 * @see org.tinytlf.ITextEngine
		 */
        function get engine():ITextEngine;
        function set engine(textEngine:ITextEngine):void;
        
        /**
		 * <p>
         * Maps a mirror Class or Function to an elementName.
		 * </p>
		 * 
         * @return True if the mirror was successfully  mapped, False
         * if it wasn't.
         */
        function mapMirror(element:*, mirrorClassOrFactory:Object):void;
		
        /**
		 * <p>
         * Unmaps the mirror Class or Function for the given element.
		 * </p>
		 * 
         * @return True if the mirror was successfully  unmapped, or False
         * if it wasn't.
         */
        function unMapMirror(element:*):Boolean;
		
		/**
		 * <p>
		 * Checks to see if this interactor has a Class or Function for the
		 * given element.
		 * </p>
		 * 
		 * @return True if there is a mirror, False if there isn't.
		 */
        function hasMirror(element:*):Boolean;
        
        /**
		 * <p>
         * Returns an EventDispatcher for an element name. Typically an
         * IContentElementFactory calls this when it creates a ContentElement 
		 * and needs to specify an eventMirror.
		 * </p>
		 * <p>
		 * If a Class was mapped, this instantiates the class and returns an
		 * instance. If a Function was mapped, this returns the value returned
		 * by calling the Function.
		 * </p>
		 * <p>
		 * If <code>element</code> is null, this method should return a generic
		 * EventDispatcher instance.
		 * </p>
         */
        function getMirror(element:* = null):EventDispatcher;
    }
}

