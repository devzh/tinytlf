/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.conversion
{
	import flash.text.engine.*;
	import flash.utils.Dictionary;
	
	import org.tinytlf.*;
	import org.tinytlf.analytics.*;
	import org.tinytlf.layout.properties.*;
	
	public class TextBlockFactoryBase implements ITextBlockFactory
	{
		private var _engine:ITextEngine;
		
		public function get engine():ITextEngine
		{
			return _engine;
		}
		
		public function set engine(textEngine:ITextEngine):void
		{
			if(textEngine == _engine)
				return;
			
			_engine = textEngine;
		}
		
		public function preRender():void
		{
		}
		
		public function getTextBlock(index:int):TextBlock
		{
			var block:TextBlock = engine.analytics.getBlockAt(index);
			
			if(block)
				return block;
			
			return textBlockGenerator.generate(data, getElementFactory(data));
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
			if(!(element in elementAdapterMap))
			{
				adapter = new ContentElementFactory();
				IContentElementFactory(adapter).engine = engine;
				return adapter;
			}
			
			adapter = elementAdapterMap[element];
			if(adapter is Class)
				adapter = IContentElementFactory(new (adapter as Class)());
			if(adapter is Function)
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
			if(!(element in elementAdapterMap))
				return false;
			
			return delete elementAdapterMap[element];
		}
		
		protected var _data:Object;
		
		public function get data():Object
		{
			return _data;
		}
		
		public function set data(value:Object):void
		{
			if(value == _data)
				return;
			
			_data = value;
			if(engine)
				engine.invalidate();
		}
		
		private var generator:ITextBlockGenerator = new TextBlockGenerator();
		
		public function get textBlockGenerator():ITextBlockGenerator
		{
			return generator;
		}
		
		public function set textBlockGenerator(blockGenerator:ITextBlockGenerator):void
		{
			if(blockGenerator == generator)
				return;
			
			generator = blockGenerator;
		}
		
		public function get numBlocks():int
		{
			return 0;
		}
	}
}
import flash.text.engine.TextBlock;

import org.tinytlf.ITextEngine;
import org.tinytlf.conversion.*;
import org.tinytlf.layout.properties.LayoutProperties;
import org.tinytlf.util.TinytlfUtil;
import org.tinytlf.util.fte.TextBlockUtil;

internal class TextBlockGenerator implements ITextBlockGenerator
{
	public function generate(data:*, factory:IContentElementFactory):TextBlock
	{
		var block:TextBlock = TextBlockUtil.checkOut();
		block.content = factory.execute(data);
		
		var props:LayoutProperties = TinytlfUtil.getLP();
		props.mergeWith(data);
		props.applyTo(block);
		props.model = data;
		block.userData = props;
		
		return block;
	}
}