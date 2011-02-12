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
    
    import org.tinytlf.analytics.ITextEngineAnalytics;
    import org.tinytlf.conversion.ITextBlockFactory;
    import org.tinytlf.decor.ITextDecor;
    import org.tinytlf.interaction.ITextInteractor;
    import org.tinytlf.layout.ITextLayout;
    import org.tinytlf.styles.ITextStyler;
    
	/**
	 * <p>The <code>ITextEngine</code> is the facade which unifies the 
	 * subsystems of tinytlf. Since tinytlf is relies on external definitions 
	 * for implementation, the engine provides access to the <code>decor</code>,
	 * <code>interactor</code>, <code>styler</code>, and <code>layout</code>. 
	 * <code>ITextEngine</code> supports external configuration through the 
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
		 * The <code>ITextEngineAnalytics</code> instance for the engine.
		 * 
		 * @see org.tinytlf.analytics.ITextEngineAnalytics
		 */
        function get analytics():ITextEngineAnalytics;
        function set analytics(textAnalytics:ITextEngineAnalytics):void;
		
		/**
		 * The ILayoutFactoryMap for tinytlf. This object accepts arbitrary data
		 * and converts it into Flash Text Engine ContentElements and TextBlocks.
		 */
		function get blockFactory():ITextBlockFactory;
		function set blockFactory(value:ITextBlockFactory):void;
		
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
		 * The scroll position of the engine. This value is in pixels. Defined
		 * centrally here, but usually only needed during layout.
		 */
        function get scrollPosition():Number;
        function set scrollPosition(value:Number):void;
        
		/**
		 * A point whose <code>x</code> property represents the engine's 
		 * selection startIndex and <code>y</code> property represents 
		 * the engine's selection endIndex.
		 */
        function get selection():Point;
        
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
        function invalidate():void;
		
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

