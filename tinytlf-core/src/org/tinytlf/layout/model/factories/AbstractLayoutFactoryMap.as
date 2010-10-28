/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout.model.factories
{
    import flash.text.engine.*;
    import flash.utils.Dictionary;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.layout.properties.*;
    import org.tinytlf.util.TinytlfUtil;

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
		
		public function beginRender():void
		{
		}
		
		public function endRender():void
		{
		}
		
		public function get nextBlock():TextBlock
		{
			return null;
		}
		
		public function cacheVisibleBlock(block:TextBlock):void
		{
		}
		
		public function clearCaches():void
		{
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
		
		
		/**
		 * Utility method which applies justification properties to the 
		 * TextBlock before it's rendered.
		 */
		protected function setupBlockJustifier(block:TextBlock):void
		{
			var props:LayoutProperties = TinytlfUtil.getLP(block);
			var justification:String = LineJustification.UNJUSTIFIED;
			var justifier:TextJustifier = TextJustifier.getJustifierForLocale(props.locale);
			
			if(props.textAlign == TextAlign.JUSTIFY)
				justification = LineJustification.ALL_BUT_LAST;
			
			justifier.lineJustification = justification;
			
			if(	!block.textJustifier || 
				block.textJustifier.lineJustification != justification || 
				block.textJustifier.locale != props.locale)
			{
				props.applyTo(justifier);
				
				block.textJustifier = justifier;
			}
		}
    }
}