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
	import flash.geom.Rectangle;
	import flash.text.engine.*;
	
	import org.tinytlf.behaviors.*;
	import org.tinytlf.gestures.IGesture;
	import org.tinytlf.layout.ITextContainer;
	import org.tinytlf.layout.properties.*;
	
	public class GestureInteractor extends TextInteractorBase implements IGestureInteractor
	{
		override public function getMirror(element:* = null):EventDispatcher
		{
			if(element is TextLine)
			{
				var line:TextLine = element as TextLine;
				line.mouseChildren = false;
				line.mouseEnabled = false;
				
//				TextLine(element).doubleClickEnabled = true;
				//TODO: This is a hack... fix this please.
				//ps. don't screw it up.
//				if(TextLine(element).getChildByName('lineCatcher') == null)
//				{
//					createBackground(TextLine(element));
//				}
			}
			if(element is ITextContainer)
			{
				ITextContainer(element).target.doubleClickEnabled = true;
				removeListeners(ITextContainer(element).target);
				addListeners(ITextContainer(element).target);
			}
			
			return super.getMirror(element);
		}
		
		public function removeListeners(target:IEventDispatcher):void
		{
			for each(var gesture:IGesture in gestures)
			{
				gesture.removeSource(target);
			}
		}
		
		public function addListeners(target:IEventDispatcher):void
		{
			for each(var gesture:IGesture in gestures)
			{
				gesture.addSource(target);
			}
		}
		
		public function addGesture(gesture:IGesture, ... behaviors):IGesture
		{
			if(_gestures.indexOf(gesture) == -1)
				_gestures.push(gesture);
			
			for each(var behavior:IBehavior in behaviors)
			{
				gesture.addBehavior(behavior);
			}
			
			return gesture;
		}
		
		public function removeGesture(gesture:IGesture):IGesture
		{
			var i:int = _gestures.indexOf(gesture);
			if(i != -1)
				_gestures.splice(i, 1);
			
			return gesture;
		}
		
		public function removeAllGestures():void
		{
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
		/*
		private function createBackground(line:TextLine):void
		{
			//Try to guess the original paragraph width.
			var lp:LayoutProperties = (line.textBlock.userData as LayoutProperties) || new LayoutProperties();
			var w:Number = line.specifiedWidth;
			w += lp.paddingLeft;
			w += lp.paddingRight;
			
			var x:Number = 0;
			var rect:Rectangle = new Rectangle(0, -line.ascent, 0, line.height);
			
			//Add in the indent if this is the first line in the TextBlock
			if(!line.previousLine)
			{
				w += lp.textIndent;
				x -= lp.textIndent;
				
				rect.y -= lp.paddingTop;
				rect.height += lp.paddingTop;
			}
			
			switch(lp.textAlign)
			{
				case TextAlign.CENTER:
				case TextAlign.RIGHT:
					x = -line.x;
					break;
			}
			
			rect.x = x;
			rect.width = w;
			
			var sprite:Sprite = new Sprite();
			sprite.name = 'lineCatcher';
			sprite.graphics.beginFill(0x00, 0.1);
			sprite.graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
			line.addChildAt(sprite, 0);
		}
		*/
	}
}