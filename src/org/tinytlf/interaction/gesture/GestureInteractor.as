/*
* Copyright (c) 2010 the original author or authors
*
* Permission is hereby granted to use, modify, and distribute this file
* in accordance with the terms of the license agreement accompanying it.
*/
package org.tinytlf.interaction.gesture
{
    import flash.events.*;
    import flash.text.engine.TextLine;
    
    import org.tinytlf.gesture.IGesture;
    import org.tinytlf.gesture.gestures.keyboard.*;
    import org.tinytlf.gesture.gestures.mouse.*;
    import org.tinytlf.interaction.TextInteractorBase;
    import org.tinytlf.interaction.gesture.behaviors.*;

    public class GestureInteractor extends TextInteractorBase implements IGestureInteractor
    {
        public function GestureInteractor()
        {
            super();
            
            var focus:FocusBehavior = new FocusBehavior();
            var iBeam:IBeamBehavior = new IBeamBehavior();
            var charSelect:CharacterSelectionBehavior = new CharacterSelectionBehavior();
            var wordSelect:WordSelectionBehavior = new WordSelectionBehavior();
            var lineSelect:LineSelectionBehavior = new LineSelectionBehavior();
            
            addGesture(new KeyboardGesture(), focus);
            addGesture(new MouseOverGesture(), iBeam);
            addGesture(new MouseOutGesture(), iBeam);
            addGesture(new MouseClickGesture(), focus, charSelect);
            addGesture(new MouseDoubleDownGesture(), wordSelect);
            addGesture(new MouseTripleDownGesture(), lineSelect);
        }
        
        override public function getMirror(element:* = null):EventDispatcher
        {
            if(element is TextLine)
            {
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
        
        private var _gestures:Vector.<IGesture> = new Vector.<IGesture>();
        
        public function get gestures():Vector.<IGesture>
        {
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
            if(event.eventPhase != EventPhase.AT_TARGET)
                return;
            
            var g:Vector.<IGesture> = gestures;
            for each(var gesture:IGesture in g)
                if(gesture.hasEventListener(event.type))
                    gesture.execute(event);
        }
    }
}