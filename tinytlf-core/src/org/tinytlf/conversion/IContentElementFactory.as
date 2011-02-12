/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.conversion
{
    import flash.text.engine.ContentElement;
    
    import org.tinytlf.ITextEngine;
    
	/**
	 * IContentElementFactory is an interface for parsing arbitrary data into
	 * Flash Text Engine ContentElements. Classes of this type are mapped to the
	 * ILayoutFactoryMap for element types, then the ILayoutFactoryMap
	 * implementation calls <code>execute</code> for each matching data type.
	 */
    public interface IContentElementFactory
    {
		/**
		 * <p>
		 * Reference to the central <code>ITextEngine</code> facade for this
		 * <code>contentElementFactory</code>.
		 * </p>
		 * 
		 * @see org.tinytlf.ITextEngine
		 */
        function get engine():ITextEngine;
        function set engine(textEngine:ITextEngine):void;
        
		/**
		 * Returns a Flash Text Engine ContentElement for the data object.
		 * Accepts arbitrary contextual parameters which implementations can
		 * harness to create specialized ContentElements.
		 * 
		 * @see org.tinytlf.layout.model.factories.LayoutFactoryMap#createBlocks()
		 */
        function execute(data:Object, ...context:Array):ContentElement;
    }
}

