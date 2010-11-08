package org.tinytlf.components.spark
{
	import flash.events.Event;
	import flash.events.EventPhase;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.ITextEngineConfiguration;
	import org.tinytlf.TextEngine;
	import org.tinytlf.components.TextColumnContainer;
	import org.tinytlf.components.TextFieldEngineConfiguration;
	import org.tinytlf.layout.ITextContainer;
	import org.tinytlf.styles.IStyleAware;
	
	import spark.components.supportClasses.GroupBase;

	public class RichTextField extends GroupBase
		/* implements IStyleAware */ //can't do this because Flex's clearStyle is retarded.
	{
		public function RichTextField()
		{
			super();
			
			measuredWidth = 100;
			configuration = new TextFieldEngineConfiguration(true, false);
			columnCount = 1;
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
			
			invalidateDisplayList();
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
			invalidateDisplayList();
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
			engine.invalidate();
		}
		
		private function onAddedToStage(event:Event):void
		{
			if(event.eventPhase != EventPhase.AT_TARGET)
				return;
			
			removeEventListener(event.type, onAddedToStage);
			engine.stage = stage;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			setContentSize(unscaledWidth, unscaledHeight);
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if(columnCount == 1)
			{
				textColumns[0].width = unscaledWidth;
				textColumns[0].height = explicitHeight;
			}
			else
			{
				var column:TextColumnContainer;
				var n:int = columnCount;
				var xx:Number = 0;
				var w:Number = Math.floor(unscaledWidth / n) - gap;
				
				for(var i:int = 0; i < n; ++i)
				{
					column = textColumns[i];
					column.width = w;
					column.height = explicitHeight;
					column.x = xx;
					xx += w + gap;
				}
			}
			
			engine.invalidate();
			engine.render();
		}
		
		override public function get contentHeight():Number
		{
			return super.contentHeight;
		}
		
		public function get style():Object
		{
			return engine.styler.style;
		}
		
		public function set style(value:Object):void
		{
			engine.styler.style = value;
		}
		
		override public function getStyle(styleProp:String):*
		{
			return engine.styler.getStyle(styleProp);
		}
		
		override public function setStyle(styleProp:String, newValue:*):void
		{
			super.setStyle(styleProp, newValue);
			
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
		
		override public function stylesInitialized():void
		{
			super.stylesInitialized();
			
			merge(this);
		}
	}
}