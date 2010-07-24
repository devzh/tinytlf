/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout.factory
{
    import flash.text.engine.TextBlock;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.layout.adapter.IContentElementAdapter;
    
    /**
     * Ultimately the job of BlockFactory is to generate TextBlocks for us. It just
     * so happens that generating TextBlocks requires the generation of
     * ContentElements as well. Thus this is the main model actor in tinyTLF.
     */
    public interface ILayoutModelFactory
    {
        function get data():Object;
        function set data(value:Object):void;
        
        function get engine():ITextEngine;
        function set engine(textEngine:ITextEngine):void;
        
        function get blocks():Vector.<TextBlock>;
        
        function createBlocks(...args):Vector.<TextBlock>;
        
        function hasElementAdapter(element:*):Boolean;
        function getElementAdapter(element:*):IContentElementAdapter;
        function mapElementAdapter(element:*, adapterClassOrInstance:Object):void;
        function unMapElementAdapter(element:*):Boolean;
    }
}

