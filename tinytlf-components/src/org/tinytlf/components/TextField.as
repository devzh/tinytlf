/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.components
{
    import com.bit101.components.VScrollBar;
    
    import flash.display.*;
    import flash.events.*;
    import flash.geom.*;
    import flash.utils.*;
    
    import org.tinytlf.*;
    import org.tinytlf.layout.*;
    import org.tinytlf.layout.constraints.*;
    import org.tinytlf.styles.*;

    public class TextField extends ComponentBase implements IStyleAware
    {
        public function TextField()
        {
            super();
            
			engine.layout.addContainer(ITextContainer(addChild(container = new TextColumnContainer())));
			container.addEventListener('initScrollBar', onInitScrollbar);
			
            width = 100;
			configuration = new TextFieldEngineConfiguration();
			layoutConstraintFactory = new HTMLConstraintFactory();
        }
		
		protected var container:TextColumnContainer;
		
        override public function set height(value:Number):void
        {
            if(height === value)
                return;
			
            super.height = value;
			container.height = value;
			scrollPosition = scrollPosition;
        }
        
        override public function set width(value:Number):void
        {
            if(width === value)
                return;
            
            super.width = value;
			
			if(scrollBar)
			{
				engine.scrollPosition = 0;
				scrollBar.value = 0;
				value = value - scrollBar.width - 5;
			}
			
			container.width = value;
			scrollPosition = scrollPosition;
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
		
		private var _editable:Boolean = false;
		public function get editable():Boolean
		{
			return _editable;
		}
		
		public function set editable(value:Boolean):void
		{
			if(value === editable)
				return;
			
			_editable = value;
			configuration = new TextFieldEngineConfiguration(selectable, editable);
		}
        
        private var _engine:ITextEngine;
        
        public function get engine():ITextEngine
        {
            if(!_engine)
            {
                _engine = new TextFieldEngine(this, stage);
                
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
		
		public function get scrollable():Boolean
		{
			return container.scrollable;
		}
		
		public function set scrollable(value:Boolean):void
		{
			container.scrollable = value;
		}
		
		protected var scrollP:Number = 0;
		
		public function get scrollPosition():Number
		{
			return scrollP;
		}
		
		public function set scrollPosition(value:Number):void
		{
			if(value != scrollP)
			{
				if(!scrollBar)
					return;
				scrollP = Math.min(Math.max(value, 0), scrollBar.maximum);
				engine.scrollPosition = scrollP;
				scrollBar.value = scrollP;
			}
			
			if(width && height)
				container.scrollRect = new Rectangle(-5, scrollP, width + 5, height);
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
		public function get text():String
		{
			return _text;
		}
		
        public function set text(value:String):void
        {
            if(_text === value)
                return;
            
            _text = value;
            engine.blockFactory.data = _text;
            engine.invalidate();
        }
		
		public function get layoutConstraintFactory():IConstraintFactory
		{
			return container.constraintFactory;
		}
		
		public function set layoutConstraintFactory(factory:IConstraintFactory):void
		{
			container.constraintFactory = factory;
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
		
		public function mergeWith(object:Object):void
		{
			engine.styler.mergeWith(object);
		}
		
		public function unmergeWith(object:Object):void
		{
			engine.styler.unmergeWith(object);
		}
		
		public function applyTo(object:Object):void
		{
			engine.styler.applyTo(object);
		}
		
		public function unapplyTo(object:Object):void
		{
			engine.styler.unapplyTo(object);
		}
		
        private function onAddedToStage(event:Event):void
        {
            if(event.eventPhase != EventPhase.AT_TARGET)
                return;
            
            removeEventListener(event.type, onAddedToStage);
            engine.stage = stage;
			
			initialize();
        }
		
		public function initialize():void
		{
		}
		
		private function onInitScrollbar(event:Event):void
		{
			event.stopPropagation();
			initScrollBar();
		}
		
		private var scrollBar:VScrollBar;
		
		protected function initScrollBar():void
		{
			if(!scrollBar)
			{
				scrollBar = new VScrollBar(this, 0, 0, onScrollChange);
				addChild(scrollBar);
				scrollBar.lineSize = 5;
				scrollBar.pageSize = 15;
				scrollBar.height = height;
				scrollBar.y = 0;
				scrollBar.minimum = 0;
				
				container.width = width - scrollBar.width - 10;
				container.scrollRect = new Rectangle(-5, 0, width + 5, height);
				
				setTimeout(engine.invalidate, 10);
			}
			
			var totalHeight:Number = container.totalHeight;
			
			scrollBar.x = width - scrollBar.width;
			scrollBar.maximum = totalHeight - height;
			scrollBar.setThumbPercent(height / totalHeight);
		}
		
		protected function onScrollChange(event:Event = null):void
		{
			if(!scrollBar)
				return;
			
			scrollPosition = scrollBar.value;
		}
    }
}
import flash.display.Stage;

import org.tinytlf.TextEngine;
import org.tinytlf.components.TextField;

internal class TextFieldEngine extends TextEngine
{
	public function TextFieldEngine(textField:TextField, stage:Stage)
	{
		tf = textField;
		
		super(stage);
	}
	private var tf:TextField;
	
	override public function get scrollPosition():Number
	{
		return tf.scrollPosition;
	}
	
	override public function set scrollPosition(value:Number):void
	{
		if(value === tf.scrollPosition)
		{
			super.scrollPosition = value;
			return;
		}
		
		tf.scrollPosition = value;
	}
}
