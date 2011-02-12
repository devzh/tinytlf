package org.tinytlf
{
    import flash.display.Sprite;
    import flash.display.Stage;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.text.engine.TextBlock;
    import flash.text.engine.TextElement;
    import flash.utils.Timer;
    
    import flexunit.framework.Assert;
    
    import mockolate.*;
    
    import mx.core.UIComponent;
    
    import org.flexunit.async.Async;
    import org.fluint.uiImpersonation.UIImpersonator;
    import org.tinytlf.conversion.*;
    import org.tinytlf.decor.*;
    import org.tinytlf.interaction.*;
    import org.tinytlf.layout.*;
    import org.tinytlf.styles.*;
    
    public class TextEngineTests
    {
        private var engineStage:Stage;
        private var engine:TextEngine;
        private var delayTimer:Timer;
        
        [Before(async, timeout=5000)]
        public function setup():void
        {
            engineStage = UIImpersonator.addChild(new UIComponent()).stage;
            engine = new TextEngine(engineStage);
            delayTimer = new Timer(1000, 1);
            Async.proceedOnEvent(this,
                                 prepare(ITextDecor, ITextBlockFactory, ITextLayout),
                                 Event.COMPLETE);
        }
        
        [After]
        public function tearDown():void
        {
            engineStage = null;
            engine = null;
            delayTimer = null;
        }
        
        [Test]
        public function text_engine_constructed():void
        {
            Assert.assertTrue(engine != null);
        }
        
        //--------------------------------------------------------------------------
        //
        //  default properties tests
        //
        //--------------------------------------------------------------------------
        
        [Test]
        public function engine_has_default_decor():void
        {
            var decor:ITextDecor = engine.decor;
            
            Assert.assertTrue(decor is TextDecor);
        }
        
        [Test]
        public function engine_has_default_block_factory():void
        {
            var factory:ITextBlockFactory = engine.blockFactory;
            
            Assert.assertTrue(factory is TextBlockFactoryBase);
        }
        
        [Test]
        public function engine_has_default_interactor():void
        {
            var interactor:ITextInteractor = engine.interactor;
            
            Assert.assertTrue(interactor is TextInteractorBase);
        }
        
        [Test]
        public function engine_has_default_layout():void
        {
            var layout:ITextLayout = engine.layout;
            
            Assert.assertTrue(layout is TextLayoutBase);
        }
        
        [Test]
        public function engine_has_default_styler():void
        {
            var styler:ITextStyler = engine.styler;
            
            Assert.assertTrue(styler is TextStyler)
        }
        
        //--------------------------------------------------------------------------
        //
        //  public method tests
        //
        //--------------------------------------------------------------------------
        
        //----------------------------------------------------
        //  invalidation triggers rendering
        //----------------------------------------------------
        
        [Test(async)]
        public function invalidate_calls_render_on_layout_after_current_frame():void
        {
            var layout:ITextLayout = nice(ITextLayout);
            stub(layout).method("render");
            
            engine.layout = layout;
            engine.invalidate();
            
            Async.handleEvent(this, delayTimer, TimerEvent.TIMER_COMPLETE,
                              handleInvalidateCallsRenderOnLayoutAfterCurrentFrame, 1500, layout);
            
            delayTimer.start();
        }
        
        private function handleInvalidateCallsRenderOnLayoutAfterCurrentFrame(event:Event, layout:ITextLayout):void
        {
            verify(layout).method("render").once();
        }
        
        [Test(async)]
        public function invalidate_calls_render_on_decor_after_current_frame():void
        {
            var decor:ITextDecor = nice(ITextDecor);
            stub(decor).method("render");
            
            engine.decor = decor;
            engine.invalidate();
            
            Async.handleEvent(this, delayTimer, TimerEvent.TIMER_COMPLETE,
                              handleInvalidateCallsRenderOnDecorAfterCurrentFrame, 1500, decor);
            
            delayTimer.start();
        }
        
        private function handleInvalidateCallsRenderOnDecorAfterCurrentFrame(event:Event, decor:ITextDecor):void
        {
            verify(decor).method("render").once();
        }
        
        [Test(async)]
        public function invalidate_calls_resetShapes_on_layout_after_current_frame():void
        {
            var layout:ITextLayout = nice(ITextLayout);
            stub(layout).method("resetShapes");
            
            engine.layout = layout;
            engine.invalidate();
            
            Async.handleEvent(this, delayTimer, TimerEvent.TIMER_COMPLETE,
                              handleInvalidateCallsResetShapesOnLayoutAfterCurrentFrame, 1500, layout);
            
            delayTimer.start();
        }
        
        private function handleInvalidateCallsResetShapesOnLayoutAfterCurrentFrame(event:Event, layout:ITextLayout):void
        {
            verify(layout).method("resetShapes").once();
        }
        
        //----------------------------------------------------
        //  rendering
        //----------------------------------------------------
        
        [Test]
        public function render_lines_renders_layout():void
        {
            var layout:ITextLayout = nice(ITextLayout);
            stub(layout).method("render");
            
            engine.layout = layout;
            engine.invalidateLines();
			engine.render();
            
            verify(layout).method("render").once();
        }
        
        [Test]
        public function render_decorations_resets_shapes_in_layout():void
        {
            var layout:ITextLayout = nice(ITextLayout);
            stub(layout).method("resetShapes");
            
            engine.layout = layout;
			engine.invalidateDecorations();
			engine.render();
            
            verify(layout).method("resetShapes").once();
        }
        
        [Test]
        public function render_decorations_renders_decor():void
        {
            var decor:ITextDecor = nice(ITextDecor);
            stub(decor).method("render");
            
            engine.decor = decor;
			engine.invalidateDecorations();
			engine.render();
            
            verify(decor).method("render").once();
        }
        
        private function renderDummyTextInEngine():void
        {
            var target:Sprite = new Sprite();
            engine.layout.addContainer(new TextContainerBase(target, 100));
            engine.blockFactory.addBlocks("Let's test this shit.");
            engine.invalidate();
            engine.render();
        }
        
        [Test]
        public function selecting_text_calls_decorate():void
        {
            renderDummyTextInEngine();
            
            var decor:ITextDecor = strict(ITextDecor);
            stub(decor).method("decorate");
            stub(decor).method("undecorate");
            stub(decor).setter("engine");
			stub(decor).method("hasDecoration");
            
            engine.decor = decor;
            
            engine.select(0, 1);
            
            verify(decor);
        }
    }
}
