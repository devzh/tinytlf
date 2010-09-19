/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf
{
    import flash.display.Stage;
    import flash.geom.Point;
    import flash.text.engine.TextBlock;
    
    import org.tinytlf.decor.ITextDecor;
    import org.tinytlf.interaction.ITextInteractor;
    import org.tinytlf.layout.ITextLayout;
    import org.tinytlf.styles.ITextStyler;
    
	/**
	 * <p>The <code>ITextEngine</code> is a facade pattern which unifies the 
	 * subsystems of tinytlf. Since tinytlf is relies on external definitions 
	 * for implementation, the engine provides access to the <code>decor</code>,
	 * <code>interactor</code>, <code>styler</code>, and <code>layout</code>, 
	 * and <code>ITextEngine</code> supports configuration through the 
	 * <code>ITextEngineConfiguration</code> interface. To apply a 
	 * configuration, write a class that implements 
	 * <code>ITextEngineConfiguration</code> and pass an instance into the
	 * <code>configuration</code> setter of <code>ITextEngine</code>.</p>
	 * <p>The <code>ITextEngine</code> is also responsible for invalidation, 
	 * selection, and the <code>TextBlock</code>s that make up a tinytlf text 
	 * field.</p>
	 * 
	 * @see org.tinytlf.decor.ITextDecor
	 * @see org.tinytlf.interaction.ITextInteractor
	 * @see org.tinytlf.layout.ITextLayout
	 * @see org.tinytlf.styles.ITextStyler
	 * @see org.tinytlf.ITextEngineConfiguration
	 */
    public interface ITextEngine
    {
		/**
		 * The index of the selection caret for the engine.
		 */
        function get caretIndex():int;
        function set caretIndex(index:int):void;
        
		/**
		 * A setter which applies an <code>ITextEngineConfiguration</code> for 
		 * this engine. <code>ITextEngineConfiguration</code> is meant to 
		 * externally map all the properties for this engine's member maps 
		 * (decoration renderers and properties on <code>ITextDecor</code>, 
		 * event mirrors, gestures, and behaviors on <code>ITextInteractor</code>,
		 * <code>IContentElementAdapters</code> for elements parsed by 
		 * <code>ITextLayout</code>'s <code>ITextBlockFactory</code> member, and
		 * style definitions for the <code>ITextStyler</code>.
		 */
		function set configuration(engineConfiguration:ITextEngineConfiguration):void;
		
		/**
		 * The <code>ITextDecor</code> instance for the engine.
		 * 
		 * @see org.tinytlf.decor.ITextDecor
		 */
        function get decor():ITextDecor;
        function set decor(textDecor:ITextDecor):void;
        
		/**
		 * The <code>ITextInteractor</code> instance for the engine.
		 * 
		 * @see org.tinytlf.interaction.ITextInteractor
		 */
        function get interactor():ITextInteractor;
        function set interactor(textInteractor:ITextInteractor):void;
        
		/**
		 * The <code>ITextLayout</code> instance for the engine.
		 * 
		 * @see org.tinytlf.layout.ITextLayout
		 */
        function get layout():ITextLayout;
        function set layout(textlayout:ITextLayout):void;
        
		/**
		 * ITextEngine invalidates by calling <code>invalidate()</code> 
		 * on Flash's Stage singleton, then validates when the <code>Event.RENDER</code>
		 * event is dispatched.
		 */
        function set stage(theStage:Stage):void;
        
		/**
		 * The <code>ITextStyler</code> instance for the engine.
		 * 
		 * @see org.tinytlf.styles.ITextStyler
		 */
        function get styler():ITextStyler;
        function set styler(textStyler:ITextStyler):void;
        
        function getBlockPosition(block:TextBlock):int;
        function getBlockSize(block:TextBlock):int;
        
		/**
		 * A point whose <code>x</code> property represents the engine's 
		 * selection startIndex and <code>y</code> property represents 
		 * the engine's selection endIndex.
		 */
        function get selection():Point;
		
        /**
        * Draws a selection decoration around text.
        */
        function select(startIndex:Number = NaN, endIndex:Number = NaN):void;
        
		/**
		 * Invalidates the lines, decorations, and optionally the data for 
		 * re-draw or parsing on the next screen refresh.
		 * 
		 * @see org.tinytlf.layout.ITextLayout
		 * @see org.tinytlf.decor.ITextDecoration
		 * @see org.tinytlf.layout.model.ILayoutModelFactory
		 */
        function invalidate(preRender:Boolean = false):void;
		
		/**
		 * An optimization to invalidate this engine's data for rendering. 
		 * When this validates, the engine tells <code>ITextLayout</code>'s 
		 * <code>ITextBlockFactory</code> to parse through the data and generate
		 * FTE <code>ContentElements</code> and <code>TextBlock</code>s for the
		 * data. This has the potential to be an expensive operation and should
		 * only be called when the backing data for the engine changes. Changes
		 * to the <code>ContentElement</code>s that represent this data don't 
		 * require a call to <code>invalidateData</code> for committal, instead 
		 * the FTE watches them and marks <code>TextLine</code>s in the relevant
		 * <code>TextBlock</code>s as invalid. To commit changes to 
		 * <code>ContentElement</code>s, call <code>ITextEngine</code>'s 
		 * <code>invalidateLines</code> method.
		 * 
		 * @see org.tinytlf.layout.ITextLayout
		 * @see org.tinytlf.layout.model.factories.ITextLayoutModelFactory
		 */
        function invalidateData():void;
		
		/**
		 * An optimization to invalidate the styles for the ContentElements that
		 * represent the TextLines rendered inside this ITextEngine. When styles
		 * change and text should be optionally re-rendered, this method marks
		 * the ContentElements for iteration on the next render cycle. If the
		 * styles cause re-rendering, this should be detected and the lines
		 * invalidated.
		 */
		function invalidateStyles():void;
		
		/**
		 * An optimization to invalidate only the lines for re-draw on the next 
		 * screen refresh. This runs <code>ITextLayout</code>'s 
		 * <code>render</code> routine, which should be optimized to only render
		 * the lines which the FTE's <code>TextBlock</code> has marked as 
		 * invalid.
		 * 
		 * @see org.tinytlf.layout.ITextLayout
		 */
        function invalidateLines():void;
		
		/**
		 * An optimization to invalidate only the decorations for re-draw on the
		 * next screen refresh. This runs the <code>ITextDecor</code>'s 
		 * <code>render</code> routine for rendering 
		 * <code>ITextDecoration</code>s.
		 * 
		 * @see org.tinytlf.decor.ITextDecoration
		 */
        function invalidateDecorations():void;
        
		/**
		 * Renders the lines and decorations if they've been invalidated.
		 */
        function render():void;
    }
}

