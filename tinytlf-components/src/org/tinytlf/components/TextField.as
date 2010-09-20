/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.components
{
    import flash.display.*;
    import flash.events.*;
    import flash.geom.Rectangle;
    
    import org.tinytlf.*;
    import org.tinytlf.decor.decorations.*;
    import org.tinytlf.layout.*;
    import org.tinytlf.styles.IStyleAware;

    public class TextField extends Sprite implements IStyleAware
    {
        public function TextField()
        {
            super();
            
            width = 100;
			configuration = new TextFieldEngineConfiguration();
			columnCount = 1;
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
			resizeColumns();
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
			resizeColumns();
        }
		
		protected var _configuration:ITextEngineConfiguration;
		public function set configuration(engineConfiguration:ITextEngineConfiguration):void
		{
			if(engineConfiguration === _configuration)
				return;
			
			//Save this configuration so we can apply it if the engine changes
			_configuration = engineConfiguration;
			
			engine.configuration = _configuration;
			engine.invalidate(true);
		}
		
		private var textColumns:Vector.<TextColumnContainer> = new <TextColumnContainer>[];
		
		public function get columnCount():int
		{
			return textColumns.length;
		}
		
		public function set columnCount(value:int):void
		{
			if(value < 1)
				value = 1;
			
			var column:TextColumnContainer;
			
			while(value > textColumns.length)
			{
				column = new TextColumnContainer();
				engine.layout.addContainer(column);
				textColumns.push(addChild(column));
			}
			
			while(value < textColumns.length)
			{
				column = TextColumnContainer(textColumns.splice(textColumns.length - 1, 1)[0]);
				engine.layout.removeContainer(ITextContainer(removeChild(column)));
			}
			
			resizeColumns();
		}
        
        private var _engine:ITextEngine;
        
        public function get engine():ITextEngine
        {
            if(!_engine)
            {
                _engine = new TextEngine(stage);
                
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
		
		private var _gap:Number = 5;
		public function get gap():Number
		{
			return _gap;
		}
		
		public function set gap(value:Number):void
		{
			if(value === _gap)
				return;
			
			_gap = value;
			resizeColumns();
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
			configuration = new TextFieldEngineConfiguration(selectable, false);
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
		
		public function merge(merge:Object):void
		{
			engine.styler.merge(merge);
		}
		
		public function applyTo(object:Object):void
		{
			engine.styler.applyTo(object);
		}
		
        private function onAddedToStage(event:Event):void
        {
            if(event.eventPhase != EventPhase.AT_TARGET)
                return;
            
            removeEventListener(event.type, onAddedToStage);
            engine.stage = stage;
        }
		
		protected function resizeColumns():void
		{
			if(columnCount == 1)
			{
				textColumns[0].width = width;
				textColumns[0].height = height;
			}
			else
			{
				var column:TextColumnContainer;
				var n:int = columnCount;
				var xx:Number = 0;
				var w:Number = Math.floor(width / n) - gap;
				
				for(var i:int = 0; i < n; ++i)
				{
					column = textColumns[i];
					column.width = w;
					column.height = height;
					column.x = xx;
					xx += w + gap;
				}
			}
			
			engine.invalidate();
		}
    }
}

