/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout
{
    import flash.display.DisplayObjectContainer;
    import flash.display.Sprite;
    import flash.text.engine.TextBlock;
    import flash.text.engine.TextLine;
    
    import org.tinytlf.ITextEngine;
    
	/**
	 * ITextContainer</code> is the layout controller for a 
	 * DisplayObjectContainer used in text layout. Tinytlf renders TextLines
	 * across multiple DisplayObjectContainers, and it delegates control 
	 * over layout and line creation to ITextContainers.
	 * 
	 * <p>For a DisplayObjectContainer to be used for layout, it must belong to
	 * an ITextContainer registered with the ITextLayout layout actor. 
	 * ITextLayout handles rendering across containers. ITextContainer 
	 * participates in layout by rendering as many lines as possible into its 
	 * target DisplayObjectContainer, then returning either:
	 * <ul>
	 * <li>the last line successfully rendered, meaning there's no more room for
	 * lines in the target DisplayObjectContainer, or</li>
	 * <li><code>null</code>, meaning all the lines from the TextBlock were
	 * rendered and there's still more space in the target 
	 * DisplayObjectContainer.</li>
	 * </ul>
	 * </p>
	 * 
	 * <p>ITextContainer exposes a <code>shapes</code> Sprite, used 
	 * for drawing decorations into the target DisplayObjectContainer.</p>
	 * 
	 * @see org.tinytlf.layout.ITextLayout
	 */
    public interface ITextContainer
    {
		/**
		 * <p>
		 * Reference to the central <code>ITextEngine</code> facade for this
		 * <code>container</code>.
		 * </p>
		 * 
		 * @see org.tinytlf.ITextEngine
		 */
        function get engine():ITextEngine;
        function set engine(textEngine:ITextEngine):void;
        
		/**
		 * <p>
		 * The target <code>DisplayObjectContainer</code> for this 
		 * <code>ITextContainer</code>. <code>TextLine</code>s are added to and 
		 * removed from the target during layout.
		 * </p>
		 * 
		 * @see org.tinytlf.layout.ITextLayout
		 */
        function get target():Sprite;
        function set target(textContainer:Sprite):void;
        
		/**
		 * <p>
		 * The Sprite which background decorations are rendered into. Background
		 * decorations exist behind the TextLines.
		 * </p>
		 * 
		 * @see org.tinytlf.decor.ITextDecor
		 * @see org.tinytlf.decor.ITextDecoration
		 */
        function get background():Sprite;
        function set background(shapesContainer:Sprite):void;
        
		/**
		 * <p>
		 * The Sprite which foreground decorations are rendered into. Foreground
		 * decorations exist in front of the TextLines.
		 * </p>
		 * 
		 * @see org.tinytlf.decor.ITextDecor
		 * @see org.tinytlf.decor.ITextDecoration
		 */
        function get foreground():Sprite;
        function set foreground(shapesContainer:Sprite):void;
        
		/**
		 * <p>
		 * The height within which to render and lay out TextLines. If this
		 * value is not set, the <code>ITextContainer</code> will render lines
		 * into this container indefinitely, never signaling that the container
		 * is full.
		 * </p>
		 */
        function get explicitHeight():Number;
        function set explicitHeight(value:Number):void;
        
		/**
		 * <p>
		 * The defined width to render TextLines during layout. If this value is
		 * not set, lines are created with <code>TextBlock</code>'s default size
		 * for <code>TextLine</code>s, 1000000.
		 * </p>
		 */
        function get explicitWidth():Number;
        function set explicitWidth(value:Number):void;
        
		/**
		 * <p>
		 * The width of the widest <code>TextLine</code> in this
		 * <code>ITextContainer</code>. If the lines aren't justified, the Flash
		 * Text Engine will attempt to render lines into a certain width. If the
		 * FTE determines an atom or word won't fit, it will defer the atom or 
		 * word to the next TextLine. The result is that the actual width of the
		 * rendered TextLine is less than the specifiedWidth.
		 * </p>
		 */
        function get measuredWidth():Number;
		
		/**
		 * <p>
		 * The measured height of all the TextLines, including lineHeight and 
		 * paddingTop/paddingBottom.
		 * </p>
		 */
        function get measuredHeight():Number;
		
		/**
		 * <p>
		 * Clears the graphics and removes all children from the 
		 * <code>shapes</code> Sprite.
		 * </p>
		 */
        function resetShapes():void;
        
		/**
		 * Called before layout inside this container begins.
		 */
        function preLayout():void;
        
		/**
		 * Renders as many <code>TextLines</code> from the specified
		 * <code>TextBlock</code> into the target as possible.
		 * 
		 * <p>There is a special contract between layout and 
		 * <code>ITextLayout#render</code>.<br/>
		 * This method is passed a TextBlock to render into the
		 * target DisplayObjectContainer. If all the lines from the
		 * TextBlock were able to be rendered into the target, this method 
		 * returns null, indicating that there is still space left in the 
		 * target. If the TextLines went out of the targets boundaries, this
		 * method returns the last TextLine that fit, indicating that there is
		 * no more room in the target and the ITextLayout should move to the
		 * next container.</p>
		 * 
		 * @see org.tinytlf.layout.ITextLayout#render
		 */
        function layout(block:TextBlock, line:TextLine):TextLine;
		
		/**
		 * Checks whether this ITextContainer has a particular TextLine.
		 */
        function hasLine(line:TextLine):Boolean;
    }
}

