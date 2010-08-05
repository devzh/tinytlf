/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout.model.factories
{
    import flash.text.engine.TextBlock;
    import flash.utils.Dictionary;
    
    import org.tinytlf.ITextEngine;

    public class AbstractLayoutFactoryMap implements ILayoutFactoryMap
    {
        private var _data:Object;

        public function get data():Object
        {
            return _data;
        }

        public function set data(value:Object):void
        {
            if (value == _data)
                return;

            _data = value;
			
			if(engine)
				engine.invalidate(true);
        }

        private var _engine:ITextEngine;

        public function get engine():ITextEngine
        {
            return _engine;
        }

        public function set engine(textEngine:ITextEngine):void
        {
            if (textEngine == _engine)
                return;

            _engine = textEngine;
        }

        protected var _blocks:Vector.<TextBlock> = new Vector.<TextBlock>();

        public function get blocks():Vector.<TextBlock>
        {
            return _blocks ? _blocks.concat() : new Vector.<TextBlock>;
        }

        public function createBlocks(... args):Vector.<TextBlock>
        {
            if(_blocks && _blocks.length)
            {
                var block:TextBlock;
                while (_blocks.length > 0)
                {
                    block = _blocks.pop();
                    if (block.firstLine)
                        block.releaseLines(block.firstLine, block.lastLine);
                }
            }

            _blocks = generateTextBlocks();

            return _blocks;
        }

        protected function generateTextBlocks():Vector.<TextBlock>
        {
            return new <TextBlock>[];
        }

        protected var elementAdapterMap:Dictionary = new Dictionary(false);

        public function hasElementAdapter(element:*):Boolean
        {
            return Boolean(element in elementAdapterMap);
        }

        public function getElementAdapter(element:*):IContentElementFactory
        {
            var adapter:*;

            //Return the generic adapter if we haven't mapped any.
            if (!(element in elementAdapterMap))
            {
                adapter = new ContentElementFactory();
                IContentElementFactory(adapter).engine = engine;
                return adapter;
            }

            adapter = elementAdapterMap[element];
            if (adapter is Class)
                adapter = IContentElementFactory(new (adapter as Class)());
            if (adapter is Function)
                adapter = IContentElementFactory((adapter as Function)());

            IContentElementFactory(adapter).engine = engine;

            return IContentElementFactory(adapter);
        }

        public function mapElementAdapter(element:*, adapterClassOrInstance:Object):void
        {
            elementAdapterMap[element] = adapterClassOrInstance;
        }

        public function unMapElementAdapter(element:*):Boolean
        {
            if (!(element in elementAdapterMap))
                return false;

            return delete elementAdapterMap[element];
        }
    }
}