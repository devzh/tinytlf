/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.components.flash
{
    import flash.display.*;
    import flash.events.*;
    import flash.geom.Rectangle;
    
    import org.tinytlf.*;
    import org.tinytlf.styles.IStyleAware;
    import org.tinytlf.decor.decorations.*;
    import org.tinytlf.layout.*;

    public class TextField extends Sprite implements IStyleAware
    {
        public function TextField()
        {
            super();
            
            width = 100;
			configuration = new TextFieldEngineConfiguration();
        }
        
        private var _height:Number = 0;
        override public function get height():Number
        {
            return _height;
        }
        
        override public function set height(value:Number):void
        {
            if(height === value)
                return;
            
            _height = value;
            container.explicitHeight = Math.max(value - 1, 0);
            engine.invalidate();
        }
        
        private var _width:Number = 0;
        override public function get width():Number
        {
            return _width;
        }
        
        override public function set width(value:Number):void
        {
            if(width === value)
                return;
            
            _width = value;
            container.explicitWidth = Math.max(value - 1, 0);
            engine.invalidate();
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
		
		protected var _configuration:ITextEngineConfiguration;
		public function set configuration(engineConfiguration:ITextEngineConfiguration):void
		{
			if(engineConfiguration === _configuration)
				return;
			
			//Save this configuration so we can apply it if the engine changes
			_configuration = engineConfiguration;
			
			engine.configuration = _configuration;
			engine.invalidate();
		}
        
        private var _container:ITextContainer;
        
        public function get container():ITextContainer
        {
            if(!_container)
                container = new TextContainerBase(this);
            
            return _container;
        }
        
        public function set container(textContainer:ITextContainer):void
        {
            if(textContainer == _container)
                return;
            
            _container = textContainer;
			
            _container.target = this;
        }
		
		private var _editable:Boolean = false;
		public function get editable():Boolean
		{
			return _editable;
		}
		
		public function set editable(value:Boolean):void
		{
			if(value === _editable)
				return;
			
			_editable = value;
			
			if(value)
			{
				_selectable = true;
			}
			
			configuration = new TextFieldEngineConfiguration(selectable, editable);
		}
		
        private var _engine:ITextEngine;
        
        public function get engine():ITextEngine
        {
            if(!_engine)
            {
                _engine = new TextEngine(stage);
                _engine.layout.addContainer(container);
                
                if(!stage)
				{
                    addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
				}
            }
            
            return _engine;
        }
        
        public function set engine(textEngine:ITextEngine):void
        {
            if(textEngine == _engine)
                return;
            
            _engine = textEngine;
			
			//If we've previously set an engine configuration, re-apply it now.
			if(_configuration)
			{
				_engine.configuration = _configuration;
			}
        }
		
		private var _selectable:Boolean = true;
		public function get selectable():Boolean
		{
			return _selectable;
		}
		
		public function set selectable(value:Boolean):void
		{
			if(value === _selectable)
				return;
			
			_selectable = value;
			configuration = new TextFieldEngineConfiguration(selectable, editable);
		}
        
        private var _text:String = "";
        public function set text(value:String):void
        {
            if(_text === value)
                return;
            
            _text = value;
            engine.layout.textBlockFactory.data = _text;
            engine.invalidate(true);
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
		
        private function onAddedToStage(event:Event):void
        {
            if(event.eventPhase != EventPhase.AT_TARGET)
                return;
            
            removeEventListener(event.type, onAddedToStage);
            engine.stage = stage;
        }
    }
}

