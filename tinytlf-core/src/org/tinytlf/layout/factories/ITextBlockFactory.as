/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout.factories
{
	import flash.text.engine.TextBlock;
	
	import org.tinytlf.ITextEngine;
	
	/**
	 * ILayoutFactoryMap parses arbitrary data and returns a Vector of 
	 * TextBlocks to tinytlf. Since generating TextBlocks also requires 
	 * generating FTE ContentElements, ILayoutFactoryMap exposes a map and a
	 * command pattern which can be harnessed while parsing hierarchical data.
	 * 
	 * <p>
	 * ILayoutFactoryMap exposes a map which lets you define 
	 * <code>IContentElementFactories</code> for an "element." The "element"
	 * type is unimportant, it just acts as a key for retrieving the factory.
	 * </p>
	 * <p>
	 * No matter what your data source, it's more than likely a tree of some 
	 * sort, since rich text is most easily represented as some sort of tree.
	 * Tinytlf provides the ILayoutFactoryMap so you can generically traverse 
	 * the tree, creating a corresponding tree of ContentElements. At each step
	 * in the recursion, if you call into the <code>ILayoutFactoryMap</code>,
	 * requesting the <code>IContentElementFactory</code> for the corresponding
	 * node, you have an algorithm that accepts external modification, but can
	 * convert from your specific data structure to FTE 
	 * <code>ContentElements</code>.
	 * </p>
	 */
	public interface ITextBlockFactory
	{
		/**
		 * The arbitrary data object that backs tinytlf's text. This actor is
		 * responsible for parsing this object and returning a Vector of 
		 * TextBlocks. This will require parsing the data into ContentElements,
		 * then generating TextBlocks for the ContentElements.
		 */
		function get data():Object;
		function set data(value:Object):void;
		
		/**
		 * Reference to the central <code>ITextEngine</code> facade for this
		 * <code>factory</code>.
		 * 
		 * @see org.tinytlf.ITextEngine
		 */
		function get engine():ITextEngine;
		function set engine(textEngine:ITextEngine):void;
		
		function beginRender():void;
		function endRender():void;
		
		/**
		 * Returns a reference to the next visible TextBlock. This method should
		 * generate the TextBlock on the fly, as keeping references to every
		 * TextBlock in the TextField is potentially expensive.
		 */
		function getTextBlock(index:int):TextBlock;
		
		/**
		 * Instructs the LayoutFactoryMap to cache the TextBlock for quick
		 * retrieval on subsequent render cycles.
		 */
		function cacheVisibleBlock(block:TextBlock):void;
		
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

