/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.decor
{
    import org.tinytlf.ITextEngine;
    import org.tinytlf.layout.ITextContainer;
    
	/**
	 * ITextDecor is the decoration actor for tinytlf. <code>ITextDecor</code> 
	 * is a map for defining text decorations, including what they're called and
	 * the classes or instances which draw the decoration.
	 * <code>ITextDecor</code> also manages the application and rendering of 
	 * decorations. Use <code>decorate</code< and <code>undecorate</code> to 
	 * apply or un-apply a decoration to an element. <code>ITextDecor</code> 
	 * handles invalidating and rendering the decorations.
	 */
    public interface ITextDecor
    {
		/**
		 * Reference to the central <code>ITextEngine</code> facade for this
		 * <code>decor</code>.
		 * 
		 * @see org.tinytlf.ITextEngine
		 */
        function get engine():ITextEngine;
        function set engine(textEngine:ITextEngine):void;
		
        /**
		 * Renders all the decorations in the text field.
		 * 
		 * @see org.tinytlf.ITextEngine#invalidateDecorations()
		 */
        function render():void;
        
		/**
		 * Removes all the decorations in the text field.
		 */
        function removeAll():void;
        
		/**
		 * Creates a decoration at the specified <code>layer</code> for the 
		 * <code>element</code> based on the <code>styleObj</code>. An optional
		 * <code>containers</code> argument can be supplied if it is known which
		 * <code>ITextContainer</code>s this decoration will render onto. This
		 * is an optimization, as the <code>ITextContainers</code> can be 
		 * determined at render time, though it can be an expensive operation.
		 * 
		 * <p>
		 * The element type is deliberately ambiguous, as it's up to the 
		 * implementor to support different types. In the core 
		 * <code>TextDecor</code>, <code>element</code> can be one of four 
		 * types:
		 * <ol>
		 * <li>A <code>flash.text.engine.ContentElement</code>.</li>
		 * <li>A <code>flash.text.engine.TextLine</code>.</li>
		 * <li>A <code>flash.geom.Rectangle</code>.</li>
		 * <li>A Vector of <code>flash.geom.Rectangle</code>s.</li>
		 * </ol>
		 * If the type is a <code>ContentElement</code>, the optional
		 * <code>containers</code> vector is ignored, as 
		 * <code>ITextContainers</code> can't be associated for a
		 * <code>ContentElement</code> until render time.
		 * </p>
		 * 
		 * <p>
		 * The <code>layer</code> property defines which layer the decoration
		 * should exist on. Smaller numbers are closer to the z-order top, with
		 * 0 being the "highest" allowed layer. The <code>ITextEngine</code>'s 
		 * caret decoration is on layer 0, and the selection decoration is on
		 * layer 1.
		 * </p>
		 * 
		 * @see org.tinytlf.decor.TextDecor
		 */
        function decorate(element:*, styleObject:Object, layer:int = 3, 
						  container:ITextContainer = null, foreground:Boolean = false):void;
		
		/**
		 * <code>Undecorate</code> has three expected functions:
		 * <ul>
		 * <li>If <code>element</code> and <code>decorationProp</code> are 
		 * specified, <code>undecorate</code> removes a the specified 
		 * <code>decorationProp</code> from the element.</li>
		 * <li>If <code>element</code> is specified with no 
		 * <code>decorationProp</code>, <code>undecorate</code> removes all 
		 * decorations for the <code>element</code>.</li>
		 * <li>If <code>decorationProp</code> is specified with no 
		 * <code>element</code>, <code>undecorate</code> removes all instances 
		 * of the decoration from all elements in the 
		 * <code>ITextDecor</code>.</li>
		 * </ul>
		 * 
		 * @see org.tinytlf.decor.ITextDecoration
		 */
        function undecorate(element:* = null, decorationProp:String = null):void;
        
		/**
		 * Associates the specified <code>decorationProp</code> with the 
		 * <code>decorationClassOrFactory</code> (decoration). The 
		 * <code>decoration</code> can be a Class reference for an object which
		 * implements <code>org.tinytlf.decor.ITextDecoration</code>, or a 
		 * Function which returns an object that implements
		 * <code>org.tinytlf.decor.ITextDecoration</code>.
		 * If <code>decoration</code> is a Class reference, the 
		 * <code>decoration</code> is instantiated and returned. If 
		 * <code>decoration</code> is a Function, the Function is called and the
		 * return value used as the <code>ITextDecoration</code> instance.
		 * 
		 * @see org.tinytlf.decor.ITextDecoration
		 */
        function mapDecoration(decorationProp:String, 
							   decorationClassOrFactory:Object):void;
		
		/**
		 * Unmaps a decoration for the specified <code>decorationProp</code>.
		 * @returns True if <code>decorationProp</code> was successfully 
		 * unmapped, False if there was an error or there was no 
		 * <code>ITextDecoration</code> mapped for this 
		 * <code>decorationProp</code>.
		 */
        function unMapDecoration(decorationProp:String):Boolean;
		
		/**
		 * Checks to see if an <code>ITextDecoration</code> has been mapped for
		 * the specified <code>decorationProp</code>.
		 * @returns True if there is an <code>ITextDecoration</code>, False if 
		 * there isn't.
		 */
        function hasDecoration(decorationProp:String):Boolean;
		
		/**
		 * Gets or instantiates an instance of an <code>ITextDecoration</code> 
		 * for the specified <code>decorationProp</code>. Optionally associates
		 * the specified <code>ITextContainer</code> with the decoration.
		 */
        function getDecoration(decorationProp:String, container:ITextContainer = null):ITextDecoration;
    }
}

