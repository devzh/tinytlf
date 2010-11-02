/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout.factories
{
    import flash.text.engine.*;
    import flash.utils.Dictionary;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.layout.properties.*;
    import org.tinytlf.util.TinytlfUtil;
    import org.tinytlf.util.fte.TextBlockUtil;

    public class TextBlockFactoryBase implements ITextBlockFactory
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
				engine.invalidate();
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
		
		protected var visibleBlocks:Vector.<TextBlock> = new <TextBlock>[];

        public function get blocks():Vector.<TextBlock>
        {
            return visibleBlocks ? visibleBlocks.concat() : new Vector.<TextBlock>;
        }
		
		// This is a sparsely populated Hashmap of TextBlocks, 
		// so we can't use a Vector here.
		protected var cachedBlocks:Array = [];
		
		//A sparse array of TextBlock positions to their index in the data.
		protected var blockPositions:SparseArray = new SparseArray();
		
		protected var listIndex:int = 0;
		
		public function beginRender():void
		{
			// Update the listIndex to the index of the
			// TextBlock at the current scrollPosition.
			listIndex = blockPositions.indexOf(engine.scrollPosition);
			if(listIndex >= 0)
				--listIndex;
			
			var j:int = -1;
			//Uncache the TextBlocks that exist before the updated listIndex.
			for(var i:int = 0; i < listIndex; i += 1)
			{
				if(i in cachedBlocks)
				{
					j = visibleBlocks.indexOf(cachedBlocks[i]);
					if(j != -1)
						visibleBlocks.splice(j, 1);
					
					TextBlockUtil.cleanBlock(TextBlock(cachedBlocks[i]));
					
					delete cachedBlocks[i];
				}
			}
		}
		
		public function endRender():void
		{
		}
		
		public function get nextBlock():TextBlock
		{
			return generateTextBlock(++listIndex);
		}
		
		public function cacheVisibleBlock(block:TextBlock):void
		{
			if(visibleBlocks.indexOf(block) == -1)
				visibleBlocks.push(block);
			
			var lp:LayoutProperties = TinytlfUtil.getLP(block);
			var blockY:Number = lp.y;
			var blockIndex:int = listIndex;
			var blockSize:Number = (lp.paddingTop + lp.height + lp.paddingBottom) || 1;
			
			if(listIndex >= blockPositions.length)
			{
				blockIndex = blockPositions.length;
				blockPositions.insert(blockIndex);
			}
			else
			{
				blockIndex = blockPositions.indexOf(blockY);
			}
			
			if(blockIndex > -1)
				blockPositions.setItemSize(blockIndex, blockSize);
			
			cachedBlocks[listIndex] = block;
		}
		
		public function clearCaches():void
		{
			visibleBlocks.length = 0;
			cachedBlocks = [];
			blockPositions.clear();
		}
		
		protected function generateTextBlock(index:int):TextBlock
		{
			if(cachedBlocks[index])
				return cachedBlocks[index];
			
			return null;
		}
		
        protected var elementAdapterMap:Dictionary = new Dictionary(false);

        public function hasElementFactory(element:*):Boolean
        {
            return Boolean(element in elementAdapterMap);
        }

        public function getElementFactory(element:*):IContentElementFactory
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

        public function mapElementFactory(element:*, adapterClassOrInstance:Object):void
        {
            elementAdapterMap[element] = adapterClassOrInstance;
        }

        public function unMapElementFactory(element:*):Boolean
        {
            if (!(element in elementAdapterMap))
                return false;

            return delete elementAdapterMap[element];
        }
    }
}