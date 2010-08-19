/*
* Copyright (c) 2010 the original author or authors
*
* Permission is hereby granted to use, modify, and distribute this file
* in accordance with the terms of the license agreement accompanying it.
*/
package org.tinytlf.interaction
{
    import flash.display.Sprite;
    import flash.events.*;
    import flash.text.engine.TextBlock;
    import flash.text.engine.TextLine;
    
    import org.tinytlf.interaction.gestures.IGesture;
    import org.tinytlf.interaction.behaviors.*;
    import org.tinytlf.interaction.gestures.keyboard.*;
    import org.tinytlf.interaction.gestures.mouse.*;
    import org.tinytlf.layout.LayoutProperties;

    public class GestureInteractor extends TextInteractorBase implements IGestureInteractor
    {
        override public function getMirror(element:* = null):EventDispatcher
        {
            if(element is TextLine)
            {
				createBackground(TextLine(element));
                removeListeners(IEventDispatcher(element));
                addListeners(IEventDispatcher(element));
            }
            
            return super.getMirror(element);
        }
        
        override public function addListeners(target:IEventDispatcher):void
        {
            super.addListeners(target);
            
            target.removeEventListener(MouseEvent.MOUSE_OVER, onRollOver);
            target.removeEventListener(MouseEvent.MOUSE_OUT, onRollOut);
        }
        
        public function addGesture(gesture:IGesture, ...behaviors):IGesture
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
			// Defensive copy. This is the only way to configure behaviors after 
			// a gesture has been mapped. Don't allow access to the real list.
            return _gestures.concat();
        }
        
        override protected function onRollOver(event:MouseEvent):void
        {
            dispatchToGestures(event);
        }
        
        override protected function onRollOut(event:MouseEvent):void
        {
            dispatchToGestures(event);
        }
        
        override protected function onMouseMove(event:MouseEvent):void
        {
            dispatchToGestures(event);
        }
        
        override protected function onMouseDown(event:MouseEvent):void
        {
            dispatchToGestures(event);
        }
        
        override protected function onMouseUp(event:MouseEvent):void
        {
            dispatchToGestures(event);
        }
        
        override protected function onClick(event:MouseEvent):void
        {
            dispatchToGestures(event);
        }
        
        override protected function onDoubleClick(event:MouseEvent):void
        {
            dispatchToGestures(event);
        }
        
        override protected function onKeyDown(event:KeyboardEvent):void
        {
            dispatchToGestures(event);
        }
        
        override protected function onKeyUp(event:KeyboardEvent):void
        {
            dispatchToGestures(event);
        }
        
        private function dispatchToGestures(event:Event):void
        {
            if(event.eventPhase == EventPhase.CAPTURING_PHASE)
                return;
            
            for each(var gesture:IGesture in gestures)
			{
                if(gesture.hasEventListener(event.type))
				{
                    gesture.execute(event);
				}
			}
        }
		
		/**
		 * Adds a catcher to the TextLine so that mouse events bubble and can be
		 * caught by the gestures.
		 * @private
		 */
		private function createBackground(line:TextLine):void
		{
			//Try to guess the original paragraph width.
			var lp:LayoutProperties = (line.textBlock.userData as LayoutProperties)  || new LayoutProperties();
			var w:Number = line.specifiedWidth;
			w += lp.paddingLeft;
			w += lp.paddingRight;
			
			//Add in the indent if this is the first line in the TextBlock
			if(!line.previousLine)
				w += lp.textIndent;
			
			var sprite:Sprite = new Sprite();
			sprite.graphics.beginFill(0x00, 0);
			sprite.graphics.drawRect(-line.x, -line.ascent, w, line.height);
			line.addChild(sprite);
		}
    }
}