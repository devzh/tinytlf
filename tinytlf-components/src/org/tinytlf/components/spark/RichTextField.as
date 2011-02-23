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
			
			engine.layout.addContainer(ITextContainer(addChild(container = new TextColumnContainer())));
			
			measuredWidth = 100;
			configuration = new TextFieldEngineConfiguration(true, false);
		}
		
		override public function set verticalScrollPosition(value:Number):void
		{
			super.verticalScrollPosition = value;
			engine.scrollPosition = value;
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
			invalidateDisplayList();
		}
		
		private var container:TextColumnContainer;
		
		private var _engine:ITextEngine;
		
		public function get engine():ITextEngine
		{
			if(!_engine)
			{
				_engine = new RichTextFieldEngine(this, stage);
				
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
			engine.blockFactory.data = _text;
			engine.invalidate();
			invalidateDisplayList();
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
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			container.width = unscaledWidth;
			container.height = unscaledHeight;
			
			engine.invalidate();
			engine.render();
			
			setContentSize(unscaledWidth, container.totalHeight);
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
			engine.styler.mergeWith(merge);
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

import flash.display.Stage;

import org.tinytlf.TextEngine;
import org.tinytlf.components.spark.RichTextField;

internal class RichTextFieldEngine extends TextEngine
{
	public function RichTextFieldEngine(textField:RichTextField, stage:Stage)
	{
		tf = textField;
		
		super(stage);
	}
	private var tf:RichTextField;
	
	override public function get scrollPosition():Number
	{
		return tf.verticalScrollPosition;
	}
	
	override public function set scrollPosition(value:Number):void
	{
		if(value === tf.verticalScrollPosition)
		{
			super.scrollPosition = value;
			return;
		}
		
		tf.verticalScrollPosition = value;
	}
}
