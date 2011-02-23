/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.conversion
{
	import flash.text.engine.TextBlock;
	
	import org.tinytlf.ITextEngine;
	
	/**
	 * ITextBlockFactory parses arbitrary data and returns a Vector of 
	 * TextBlocks to tinytlf. Since generating TextBlocks also requires 
	 * generating FTE ContentElements, ITextBlockFactory exposes a map and a
	 * command pattern which can be harnessed while parsing hierarchical data.
	 * 
	 * <p>
	 * ITextBlockFactory exposes a map which lets you define 
	 * <code>IContentElementFactories</code> for an "element." The "element"
	 * type is unimportant, it just acts as a key for retrieving the factory.
	 * </p>
	 * <p>
	 * No matter what your data source, it's more than likely a tree of some 
	 * sort, since rich text is most easily represented as some sort of tree.
	 * Tinytlf provides the ITextBlockFactory so you can generically traverse 
	 * the tree, creating a corresponding tree of ContentElements. At each step
	 * in the recursion, if you call into the <code>ITextBlockFactory</code>,
	 * requesting the <code>IContentElementFactory</code> for the corresponding
	 * node, you have an algorithm that accepts external modification, but can
	 * convert from your specific data structure to FTE 
	 * <code>ContentElements</code>.
	 * </p>
	 */
	public interface ITextBlockFactory
	{
		/**
		 * Reference to the central <code>ITextEngine</code> facade for this
		 * <code>factory</code>.
		 * 
		 * @see org.tinytlf.ITextEngine
		 */
		function get engine():ITextEngine;
		function set engine(textEngine:ITextEngine):void;
		
		function get data():Object;
		function set data(value:Object):void;
		
		function get textBlockGenerator():ITextBlockGenerator;
		function set textBlockGenerator(value:ITextBlockGenerator):void;
		
		/**
		 * The number of potential discreet TextBlock instances that this
		 * ITextBlockFactory can create. This number is incremented
		 * and decremented when you make calls to addBlockData/removeBlockData.
		 * 
		 * This does not represent the number of TextBlocks currently in
		 * existance, only the number of potential blocks.
		 */
		function get numBlocks():int;
		
		/**
		 * Called during the ITextEngine render phase, just before the
		 * ITextLayoutBase#render() method is called.
		 * 
		 * This provides an opportunity to invalidate the visible TextBlocks,
		 * gather up orphan lines, and anything else that the render algorithm
		 * may depend on being done.
		 */
		function preRender():void;
		
		/**
		 * Returns a reference to the next visible TextBlock. This method should
		 * generate the TextBlock on the fly, as keeping references to every
		 * TextBlock in the TextField is potentially expensive.
		 */
		function getTextBlock(index:int):TextBlock;
		
		/**
		 * Checks to see if an <code>IContentElementFactory</code> class has 
		 * mapped for the given element.
		 * 
		 * @Returns true if a factory has been mapped, false otherwise.
		 * 
		 * @see org.tinytlf.layout.model.factories.IContentElementFactory
		 */
		function hasElementFactory(element:*):Boolean;
		
		/**
		 * Returns an IContentElementFactory instance for the given element.
		 * 
		 * @see org.tinytlf.layout.model.factories.IContentElementFactory
		 */
		function getElementFactory(element:*):IContentElementFactory;
		
		/**
		 * Maps an <code>IContentElementFactory</code> for the given element.
		 * 
		 * @see org.tinytlf.layout.model.factories.IContentElementFactory
		 */
		function mapElementFactory(element:*, classOrFactory:Object):void;
		
		/**
		 * Unmaps the given element.
		 * 
		 * @see org.tinytlf.layout.model.factories.IContentElementFactory
		 */
		function unMapElementFactory(element:*):Boolean;
	}
}

