/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout
{
	import flash.text.engine.TextLine;
	
	import org.tinytlf.ITextEngine;
	
	/**
	 * ITextLayout is the tinytlf text layout actor. ITextLayout is responsible
	 * for:
	 * <ul>
	 * <li>Parsing the TextField data into Flash Text Engine ContentElements.</li>
	 * <li>Laying out a Vector of TextBlocks across multiple 
	 * DisplayObjectContainers.</li>
	 * </ul>
	 * 
	 * <p>ITextLayout's <code>textBlockFactory</code> transforms the data into
	 * Flash Text Engine ContentElements and TextBlocks. This is the closest
	 * thing tinytlf has to a "Model" actor. The data can be in any format, as
	 * long as you can write a conversion or parsing routine to generate
	 * ContentElements and TextBlocks.</p>
	 * 
	 * <p>ITextLayout maintains a list of ITextContainers, which are layout
	 * controllers that manage text layout inside DisplayObjectContainers.</p>
	 * 
	 * @see org.tinytlf.layout.model.factories.ILayoutFactoryMap
	 * @see org.tinytlf.layout.ITextContainer
	 */
	public interface ITextLayout
	{
		/**
		 * A read-only list of ITextContainers on this layout. To add and remove
		 * containers, use <code>addContainer</code> and
		 * <code>removeContainer</code> instead.
		 * 
		 * @see org.tinytlf.layout.ITextContainer
		 */
		function get containers():Vector.<ITextContainer>;
		
		/**
		 * <p>
		 * Reference to the central <code>ITextEngine</code> facade for this
		 * <code>layout</code>.
		 * </p>
		 * 
		 * @see org.tinytlf.ITextEngine
		 */
		function get engine():ITextEngine;
		function set engine(textEngine:ITextEngine):void;
		
		/**
		 * Adds an ITextContainer to be managed and used in layout.
		 * 
		 * @see org.tinytlf.layout.ITextContainer
		 */
		function addContainer(container:ITextContainer):void;
		
		/**
		 * Removes an ITextContainer from use in layout.
		 * 
		 * @see org.tinytlf.layout.ITextContainer
		 */
		function removeContainer(container:ITextContainer):void;
		
		/**
		 * Returns the ITextContainer that a particular TextLine exists in.
		 * Returns null if no container was found to the line.
		 */
		function getContainerForLine(line:TextLine):ITextContainer;
		
		/**
		 * Clears the graphics context and removes all children of each shapes
		 * sprite on each ITextContainer.
		 * 
		 * @see org.tinytlf.layout.ITextContainer#resetShapes()
		 */
		function resetShapes():void;
		
		/**
		 * Renders as many lines from the Vector of TextBlocks as possible.
		 * 
		 * <p>This method attempts to render as many TextLines from each 
		 * TextBlock into the available ITextContainers as possible. A special
		 * contract exists between <code>render</code> and 
		 * <code>org.tinytlf.layout.ITextContainer#layout</code>: #render() 
		 * passes a TextBlock and the previously rendered line to 
		 * <code>layout</code>, and <code>layout</code> returns either:
		 * <ul>
		 * <li>The last line rendered out of the TextBlock, which indicates that
		 * there is no more space in the ITextContainer, and this ITextLayout
		 * should move on to the next ITextContainer, keeping the same 
		 * TextBlock, or</li>
		 * <li><code>null</code> indicating that there are no more lines in the
		 * TextBlock but still more space in the ITextContainer, and this
		 * ITextLayout should move on to the next TextBlock, keeping the same
		 * ITextContainer.</li>
		 * </ul>
		 * </p>
		 * 
		 * <p>This method quits either when all the lines have been rendered
		 * into the ITextContainers, or all the ITextContainers are full of
		 * TextLines.</p>
		 * 
		 * @see org.tinytlf.layout.ITextContainer#layout()
		 */
		function render():void;
	}
}

