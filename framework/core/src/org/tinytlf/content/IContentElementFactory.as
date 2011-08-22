/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.content
{
    import flash.text.engine.*;
    
    import org.tinytlf.html.IDOMNode;
    
	/**
	 * IContentElementFactory is an interface for parsing arbitrary data into
	 * Flash Text Engine ContentElements. Classes of this type are mapped to the
	 * ILayoutFactoryMap for element types, then the ILayoutFactoryMap
	 * implementation calls <code>execute</code> for each matching data type.
	 */
    public interface IContentElementFactory
    {
		/**
		 * Returns a Flash Text Engine ContentElement for the data object.
		 * Accepts arbitrary contextual parameters which implementations can
		 * harness to create specialized ContentElements.
		 */
        function create(dom:IDOMNode):ContentElement;
    }
}

