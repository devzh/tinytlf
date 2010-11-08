/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.interaction
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.engine.*;
	
	import org.tinytlf.interaction.behaviors.*;
	import org.tinytlf.interaction.gestures.IGesture;
	import org.tinytlf.interaction.gestures.keyboard.*;
	import org.tinytlf.interaction.gestures.mouse.*;
	import org.tinytlf.layout.properties.*;
	
	public class GestureInteractor extends TextInteractorBase implements IGestureInteractor
	{
		override public function getMirror(element:* = null):EventDispatcher
		{
			if(element is TextLine)
			{
				TextLine(element).doubleClickEnabled = true;
				//TODO: This is a hack... fix this please.
				//ps. don't screw it up.
				if(TextLine(element).getChildByName('lineCatcher') == null)
				{
					createBackground(TextLine(element));
					removeListeners(IEventDispatcher(element));
					addListeners(IEventDispatcher(element));
				}
			}
			
			return super.getMirror(element);
		}
		
		public function removeListeners(target:IEventDispatcher):void
		{
		}
		
		public function addGesture(gesture:IGesture, ... behaviors):IGesture
		{
			if(_gestures.indexOf(gesture) == -1)
				_gestures.push(gesture);
			
			for each(var behavior:IEventDispatcher in behaviors)
			{
				gesture.addBehavior(behavior);
			}
			
			gesture.target = this;
			
			return gesture;
		}
		
		public function removeGesture(gesture:IGesture):IGesture
		{
			var i:int = _gestures.indexOf(gesture);
			if(i != -1)
				_gestures.splice(i, 1);
			
			gesture.target = null;
			
			return gesture;
		}
		
		public function removeAllGestures():void
		{
			for each(var gesture:IGesture in gestures)
			{
				gesture.target = null;
			}
			
			_gestures.length = 0;
		}
		
		private var _gestures:Vector.<IGesture> = new Vector.<IGesture>();
		
		public function get gestures():Vector.<IGesture>
		{
			return _gestures.concat(); // Defensive copy.
			// This is the only way to configure behaviors after 
			// a gesture has been mapped. Don't allow access to the real list.
			// Provided so it can be searched, behaviors should be added to the
			// gesture itself, or by calling addGesture with an existing gesture
			// instance, passing in the new behaviors to be added.
		}
		
		/**
		 * @private
		 * Adds a catcher to the TextLine so that mouse events bubble and can be
		 * caught by the gestures.
		 */
		private function createBackground(line:TextLine):void
		{
			//Try to guess the original paragraph width.
			var lp:LayoutProperties = (line.textBlock.userData as LayoutProperties) || new LayoutProperties();
			var w:Number = line.specifiedWidth;
			w += lp.paddingLeft;
			w += lp.paddingRight;
			
			var x:Number = 0;
			
			//Add in the indent if this is the first line in the TextBlock
			if(!line.previousLine)
			{
				w += lp.textIndent;
				x -= lp.textIndent;
			}
			
			switch(lp.textAlign)
			{
				case TextAlign.CENTER:
				case TextAlign.RIGHT:
					x = -line.x;
					break;
			}
			
			var sprite:Sprite = new Sprite();
			sprite.name = 'lineCatcher';
			sprite.graphics.beginFill(0x00, 0);
			sprite.graphics.drawRect(x, -line.ascent, w, line.height);
			line.addChild(sprite);
		}
	}
}