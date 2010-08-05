/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout.model.factories
{
    import flash.text.engine.TextBlock;
    
    import org.tinytlf.ITextEngine;
    
    /**
     * ILayoutModelFactory is generates TextBlocks. This requires the generation
	 * of ContentElements as well. Thus this is the main "model" actor in tinytlf.
     */
    public interface ILayoutFactoryMap
    {
        function get data():Object;
        function set data(value:Object):void;
        
        function get engine():ITextEngine;
        function set engine(textEngine:ITextEngine):void;
        
        function get blocks():Vector.<TextBlock>;
        
        function createBlocks(...args):Vector.<TextBlock>;
        
        function hasElementAdapter(element:*):Boolean;
        function getElementAdapter(element:*):IContentElementFactory;
        function mapElementAdapter(element:*, adapterClassOrInstance:Object):void;
        function unMapElementAdapter(element:*):Boolean;
    }
}

