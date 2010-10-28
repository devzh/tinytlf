/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.decor
{
    import flash.events.IEventDispatcher;
    import flash.geom.Rectangle;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.layout.ITextContainer;
    import org.tinytlf.styles.IStyleAware;
    
	/**
	 * <p>
	 * <code>ITextDecoration</code> is the interface for objects which draw
	 * decorations to the display list.
	 * </p>
	 * <p>
	 * An <code>ITextDecoration</code> is a single text decoration, such as a
	 * background color, underline, etc. A decoration draws onto the 
	 * <code>shapes</code> Sprite of an <code>ITextContainer</code>. The
	 * decoration's <code>setup</code> method preps the decoration for rendering
	 * and returns a Vector of <code>flash.geom.Rectangle</code>s which
	 * represent the area within which this decoration should render. The
	 * decoration's <code>draw</code> method is passed the output from the
	 * <code>setup</code> method, and should use the 
	 * <code>flash.geom.Rectangle</code>s for guidance in rendering decorations.
	 * </p>
	 * <p>
	 * Because tinytlf supports multi-container layouts, a decoration can span
	 * <code>DisplayObjectContainers</code>. Therefore it is necessary to 
	 * specify a vector of associated <code>ITextContainer</code> instances for
	 * decorations, so they know which Sprites to draw into.
	 * </p>
	 * <p>
	 * Note: A decoration shares the same layer sprite with other decoration
	 * instances. It is not necessary to call graphics.clear() in the 
	 * <code>draw</code>, that will clear the previously rendered decorations.
	 * The <code>ITextContainer</code> should take care of clearing the display
	 * list before each rendering cycle.
	 * </p>
	 */
    public interface ITextDecoration extends IStyleAware
    {
        function get container():ITextContainer;
        function set container(textContainer:ITextContainer):void;
        
        function get engine():ITextEngine;
        function set engine(textEngine:ITextEngine):void;
        
		/**
		 * Whether this decoration is in the foreground (on top of the TextLines)
		 * or in the background (behind the TextLines).
		 */
		function set foreground(value:Boolean):void;
		
		/**
		 * <p>
		 * Prepares this decoration for rendering. <code>Setup</code> takes its
		 * input and should return a Vector of 
		 * <code>flash.geom.Rectangle</code>s which can be passed to 
		 * <code>draw</code>.
		 * <p>
		 * <code>Setup</code> accepts a variable number of 
		 * arguments, but in tinytlf core, the second argument is the 
		 * <code>element</code> passed into <code>ITextDecor#decorate()</code>.
		 * </p>
		 * <p>
		 * This interface is non-restrictive. If there's more information that 
		 * your custom <code>ITextDecoration</code> needs, feel free to pass it
		 * in.
		 * </p>
		 * 
		 * @see org.tinytlf.decor.ITextDecor#decorate()
		 */
        function setup(layer:int = 2, ...args):Vector.<Rectangle>;
        
		/**
		 * <p>
		 * Renders the decoration to the display list. <code>Draw</code> accepts
		 * a Vector of <code>flash.geom.Rectangle</code>s which represent the
		 * area within which to render the decoration. For example, an underline
		 * decoration would draw a thin line along the bottom of each 
		 * <code>Rectangle</code>.
		 * </p>
		 */
        function draw(bounds:Vector.<Rectangle>):void;
        
		/**
		 * Called when a decoration is removed from an element. Cleans up any 
		 * artifacts left behind from the decoration.
		 * 
		 * @see org.tinytlf.decor.ITextDecor#undecorate
		 */
        function destroy():void;
    }
}

