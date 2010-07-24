/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.EventPhase;
    import flash.geom.Rectangle;
    import flash.text.engine.TextLine;
    
    import org.tinytlf.core.IStyleAware;
    import org.tinytlf.decor.decorations.BackgroundColorDecoration;
    import org.tinytlf.decor.decorations.CaretDecoration;
    import org.tinytlf.decor.decorations.SelectionDecoration;
    import org.tinytlf.decor.decorations.StrikeThroughDecoration;
    import org.tinytlf.decor.decorations.UnderlineDecoration;
    import org.tinytlf.extensions.interaction.xml.html.CSSInteractor;
    import org.tinytlf.layout.ITextContainer;
    import org.tinytlf.layout.TextContainerBase;

    public class TextField extends Sprite implements IStyleAware
    {
        public function TextField()
        {
            super();
            
            width = 100;
        }
        
        private var _height:Number = 0;
        override public function get height():Number
        {
            return _height;
        }
        
        override public function set height(value:Number):void
        {
            if(!changed(height, value))
                return;
            
            _height = value;
            container.explicitHeight = Math.max(value - 1, 0);
            hookEngine();
            engine.invalidate();
        }
        
        private var _width:Number = 0;
        override public function get width():Number
        {
            return _width;
        }
        
        override public function set width(value:Number):void
        {
            if(!changed(width, value))
                return;
            
            _width = value;
            container.explicitWidth = Math.max(value - 1, 0);
            hookEngine();
            engine.invalidate();
        }
        
        override public function addChild(child:DisplayObject):DisplayObject
        {
            return super.addChild(child is TextLine ? hookLine(child) : child);
        }
        
        override public function getBounds(targetCoordinateSpace:DisplayObject):Rectangle
        {
            var bounds:Rectangle = super.getBounds(targetCoordinateSpace);
            
            bounds.width = _width;
            bounds.height = _height || container.measuredHeight;
            bounds.left = 0;
            bounds.right = _width;
            
            return bounds;
        }
        
        private var _container:ITextContainer;
        
        public function get container():ITextContainer
        {
            if(!_container)
                _container = new TextContainerBase(this);
            
            return _container;
        }
        
        public function set container(textContainer:ITextContainer):void
        {
            if(textContainer == _container)
                return;
            
            _container = textContainer;
            _container.target = this;
        }
        
        private var _engine:ITextEngine;
        
        public function get engine():ITextEngine
        {
            if(!_engine)
            {
                _engine = new TextEngine(stage);
                _engine.layout.addContainer(container);
                
                if(!stage)
                    addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
            }
            
            return _engine;
        }
        
        public function set engine(textEngine:ITextEngine):void
        {
            if(textEngine == _engine)
                return;
            
            _engine = textEngine;
        }
        
        private var _text:String = "";
        public function set text(value:String):void
        {
            if(!changed(_text, value))
                return;
            
            _text = value;
            engine.layout.textBlockFactory.data = _text;
            hookEngine();
            engine.prerender();
            engine.invalidate();
        }
        
        public function get style():Object
        {
            return engine.styler.style;
        }
        
        public function set style(value:Object):void
        {
            engine.styler.style = value;
        }
        
        public function clearStyle(styleProp:String):Boolean
        {
            return engine.styler.clearStyle(styleProp);
        }
        
        public function getStyle(styleProp:String):*
        {
            return engine.styler.getStyle(styleProp);
        }
        
        public function setStyle(styleProp:String, newValue:*):void
        {
            engine.styler.setStyle(styleProp, newValue);
        }
        
        /**
         * @private
         * Called just before a line is added to the display list.
         */
        protected function hookLine(line:DisplayObject):DisplayObject
        {
            return line;
        }
        
        /**
         * @private
         * Called from the constructor, maps in all the properties that the engine
         * uses.
         */
        protected function hookEngine():void
        {
            //Default mapped text decorations.
            if(!engine.decor.hasDecoration("backgroundColor"))
                engine.decor.mapDecoration("backgroundColor", BackgroundColorDecoration);
            if(!engine.decor.hasDecoration("selectionColor"))
                engine.decor.mapDecoration("selectionColor", SelectionDecoration);
            if(!engine.decor.hasDecoration("underline"))
                engine.decor.mapDecoration("underline", UnderlineDecoration);
            if(!engine.decor.hasDecoration("strikethrough"))
                engine.decor.mapDecoration("strikethrough", StrikeThroughDecoration);
            if(!engine.decor.hasDecoration("caret"))
                engine.decor.mapDecoration("caret", CaretDecoration);
            
            if(!engine.interactor.hasMirror("a"))
                engine.interactor.mapMirror("a", CSSInteractor);
        }
        
        private function onAddedToStage(event:Event):void
        {
            if(event.eventPhase != EventPhase.AT_TARGET)
                return;
            
            removeEventListener(event.type, onAddedToStage);
            engine.stage = stage;
        }
        
        private function changed(oldVal:*, newVal:*):Boolean
        {
            return Boolean(newVal !== oldVal);
        }
    }
}

