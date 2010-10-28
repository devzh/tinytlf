/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout
{
	import flash.text.engine.*;
	import flash.utils.Dictionary;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.layout.model.factories.*;
	import org.tinytlf.layout.properties.*;
	import org.tinytlf.util.TinytlfUtil;
	
	public class TextLayoutBase implements ITextLayout
	{
		protected var _engine:ITextEngine;
		
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
		
		protected var _textBlockFactory:ILayoutFactoryMap;
		
		public function get textBlockFactory():ILayoutFactoryMap
		{
			if(!_textBlockFactory)
				textBlockFactory = new AbstractLayoutFactoryMap();
			
			return _textBlockFactory;
		}
		
		public function set textBlockFactory(value:ILayoutFactoryMap):void
		{
			if(value === _textBlockFactory)
				return;
			
			_textBlockFactory = value;
			
			_textBlockFactory.engine = engine;
		}
		
		/**
		 * Clears the shapes out of this Layout's ITextContainers.
		 */
		public function resetShapes():void
		{
			for(var i:int = 0; i < containers.length; i++)
			{
				containers[i].resetShapes();
			}
		}
		
		protected var _containers:Vector.<ITextContainer> = new Vector.<ITextContainer>;
		
		public function get containers():Vector.<ITextContainer>
		{
			return _containers ? _containers.concat() : new Vector.<ITextContainer>;
		}
		
		public function addContainer(container:ITextContainer):void
		{
			if(containers.indexOf(container) != -1)
				return;
			
			_containers.forEach(function(c:ITextContainer, ...args):void{
				c.scrollable = false;
			});
			
			_containers.push(container);
			container.engine = engine;
			container.scrollable = true;
		}
		
		public function removeContainer(container:ITextContainer):void
		{
			var i:int = containers.indexOf(container);
			if(i == -1)
				return;
			
			_containers.splice(i, 1);
			container.engine = null;
		}
		
		public function getContainerForLine(line:TextLine):ITextContainer
		{
			var n:int = containers.length;
			
			for(var i:int = 0; i < n; i++)
			{
				if(containers[i].hasLine(line))
				{
					return containers[i];
				}
			}
			
			return null;
		}
		
		/**
		 * Renders all the TextLines from the list of TextBlocks into this
		 * layout's ITextContainers.
		 *
		 * <p>
		 * Each TextBlock can be in one of three states:
		 * <ul>
		 * <li>TextBlock has rendered no TextLines, and needs the entire layout pass,</li>
		 * <li>The TextBlock has previously rendered TextLines, but needs to re-render certain invalid TextLines,</li>
		 * <li>The TextBlock has rendered all the TextLines and has no invalid TextLines.</li>
		 * </ul>
		 *
		 * This method handles the first two cases, and skips to the next
		 * TextBlock if we encounter the third case.
		 * </p>
		 */
		public function render():void
		{
			if(!containers || !containers.length)
				return;
			
			containers.forEach(function(c:ITextContainer, ... args):void{
				c.preLayout();
			});
			
			textBlockFactory.beginRender();
			
			var block:TextBlock = textBlockFactory.nextBlock;
			var container:ITextContainer = containers[0];
			
			while(block && container)
			{
				container = renderBlockAcrossContainers(block, container);
				
				textBlockFactory.cacheVisibleBlock(block);
				block.releaseLineCreationData();
				
				// Only call nextBlock if there's a container.
				// Don't want to cause unnecessary processing if there's no
				// place to render the lines.
				if(container)
					block = textBlockFactory.nextBlock;
			}
			
			textBlockFactory.endRender();
		}
		
		/**
		 * Renders all the lines from the input TextBlock into the containers,
		 * starting from the container specified by <code>startContainer</code>.
		 *
		 * This method should render every line from the TextBlock into the
		 * ITextContainers.
		 *
		 * @returns The last ITextContainer rendered into, including null if
		 * there are no containers left.
		 */
		protected function renderBlockAcrossContainers(block:TextBlock, 
													   startContainer:ITextContainer):ITextContainer
		{
			if(!containers || !containers.length)
				return startContainer;
			
			var container:ITextContainer = startContainer;
			var containerIndex:int = containers.indexOf(container);
			
			var line:TextLine = container.layout(block, null);
			
			while(line)
			{
				if(++containerIndex < containers.length)
					container = containers[containerIndex];
				else
					return null;
				
				line = container.layout(block, line);
			}
			
			return container;
		}
	}
}

