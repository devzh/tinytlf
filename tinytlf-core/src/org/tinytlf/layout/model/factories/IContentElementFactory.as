/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout.model.factories
{
    import flash.text.engine.ContentElement;
    
    import org.tinytlf.ITextEngine;
    
    public interface IContentElementFactory
    {
        function get engine():ITextEngine;
        function set engine(textEngine:ITextEngine):void;
        
        function execute(data:Object, ...context:Array):ContentElement;
    }
}

