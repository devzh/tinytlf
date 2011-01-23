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
    
    import org.tinytlf.*;
    import org.tinytlf.analytics.*;
    import org.tinytlf.layout.properties.*;

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
		
		public function get analytics():ITextEngineAnalytics
		{
			return engine.analytics;
		}
		
		protected var listIndex:int = 0;
		
		public function beginRender():void
		{
			// Update the listIndex to the index of the
			// TextBlock at the current scrollPosition.
			listIndex = analytics.indexAtPixel(engine.scrollPosition);
			if(listIndex >= 0)
				--listIndex;
			
			//Uncache the TextBlocks that exist before the updated listIndex.
			for(var i:int = 0; i < listIndex; i += 1)
			{
				analytics.removeBlockAt(i);
			}
		}
		
		public function endRender():void
		{
		}
		
		public function getTextBlock(index:int):TextBlock
		{
			listIndex = index;
			return generateTextBlock(index);
		}
		
		public function cacheVisibleBlock(block:TextBlock):void
		{
			analytics.addBlockAt(block, listIndex);
		}
		
		protected function generateTextBlock(index:int):TextBlock
		{
			return analytics.getBlockAt(index);
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

        public function mapElementFactory(element:*, classOrFactory:Object):void
        {
            elementAdapterMap[element] = classOrFactory;
        }

        public function unMapElementFactory(element:*):Boolean
        {
            if (!(element in elementAdapterMap))
                return false;

            return delete elementAdapterMap[element];
        }
    }
}