/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout
{
	import flash.text.engine.LineJustification;
	import flash.text.engine.SpaceJustifier;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextJustifier;
	import flash.text.engine.TextLine;
	import flash.utils.Dictionary;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.layout.properties.TextAlign;
	import org.tinytlf.layout.model.factories.AbstractLayoutFactoryMap;
	import org.tinytlf.layout.model.factories.ILayoutFactoryMap;
	import org.tinytlf.layout.properties.LayoutProperties;
	
	public class TextLayoutBase implements ITextLayout
	{
		protected var _engine:ITextEngine;
		
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
		
		protected var _textBlockFactory:ILayoutFactoryMap;
		
		public function get textBlockFactory():ILayoutFactoryMap
		{
			if (!_textBlockFactory)
				textBlockFactory = new AbstractLayoutFactoryMap();
			
			return _textBlockFactory;
		}
		
		public function set textBlockFactory(value:ILayoutFactoryMap):void
		{
			if (value === _textBlockFactory)
				return;
			
			_textBlockFactory = value;
			
			_textBlockFactory.engine = engine;
		}
		
		/**
		 * Clears all the TextLines from this Layout's ITextContainers.
		 */
		public function clear():void
		{
			for (var i:int = 0; i < containers.length; i++)
			{
				containers[i].clear();
			}
		}
		
		/**
		 * Clears the shapes out of this Layout's ITextContainers.
		 */
		public function resetShapes():void
		{
			for (var i:int = 0; i < containers.length; i++)
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
			if (containers.indexOf(container) != -1)
				return;
			
			_containers.push(container);
			container.engine = engine;
		}
		
		public function removeContainer(container:ITextContainer):void
		{
			var i:int = containers.indexOf(container);
			if (i == -1)
				return;
			
			_containers.splice(i, 1);
			container.engine = null;
		}
		
		public function getContainerForLine(line:TextLine):ITextContainer
		{
			var n:int = containers.length;
			
			for (var i:int = 0; i < n; i++)
			{
				if (containers[i].hasLine(line))
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
		public function render(blocks:Vector.<TextBlock>):void
		{
			if (!containers || !containers.length || !blocks || !blocks.length)
				return;
			
			var block:TextBlock = blocks[0];
			var i:int = 0;
			var container:ITextContainer = containers[0];
			
			while (block && container)
			{
				setupBlockJustifier(block);
				
				//Do we need to re-render the invalid TextLines?
				if (block.firstInvalidLine)
				{
					recreateTextLines(block);
				}
				//Otherwise, do we need to do the full layout pass?
				else if (!block.firstLine)
				{
					container = renderBlockAcrossContainers(block, container);
				}
				
				block = ++i < blocks.length ? blocks[i] : null;
			}
		}
		
		/**
		 * Applies the justification properties to the TextBlock before it's rendered.
		 */
		protected function setupBlockJustifier(block:TextBlock):void
		{
			var props:LayoutProperties = (block.userData as LayoutProperties) || new LayoutProperties();
			var justification:String = LineJustification.UNJUSTIFIED;
			var justifier:TextJustifier = TextJustifier.getJustifierForLocale(props.locale);
			
			if (props.textAlign == TextAlign.JUSTIFY)
				justification = LineJustification.ALL_BUT_LAST;
			
			justifier.lineJustification = justification;
			
			if (!block.textJustifier || block.textJustifier.lineJustification != justification || block.textJustifier.locale != props.locale)
			{
				props.applyTo(justifier);
				
				block.textJustifier = justifier;
			}
		}
		
		/**
		 * Renders all the lines from the input TextBlock into the containers,
		 * starting from the container specified by <code>startContainer</code>.
		 *
		 * This method should render every line from the TextBlock into the
		 * ITextContainers.
		 *
		 * @returns The last ITextContainer rendered into.
		 */
		protected function renderBlockAcrossContainers(block:TextBlock, startContainer:ITextContainer):ITextContainer
		{
			if (!containers || !containers.length)
				return startContainer;
			
			var container:ITextContainer = startContainer;
			var containerIndex:int = containers.indexOf(container);
			
			var line:TextLine = container.layout(block, block.lastLine);
			while (line)
			{
				if(++containerIndex < containers.length)
					container = containers[containerIndex];
				else
					return null;
				
				line = container.layout(block, line);
			}
			
			container.postLayout();
			
			return container;
		}
		
		/**
		 * Recreates each of the TextBlock's invalid TextLines.
		 */
		protected function recreateTextLines(block:TextBlock):void
		{
			var touchedContainers:Dictionary = new Dictionary(true);
			var line:TextLine;
			var container:ITextContainer;
			
			while (block.firstInvalidLine)
			{
				line = block.firstInvalidLine;
				container = getContainerForLine(line);
				
				if (!container)
					break;
				
				touchedContainers[container] = true;
				container.recreateTextLine(line);
			}
			
			for (var tmp:* in touchedContainers)
			{
				ITextContainer(tmp).cleanupLines(block);
			}
		}
	}
}

