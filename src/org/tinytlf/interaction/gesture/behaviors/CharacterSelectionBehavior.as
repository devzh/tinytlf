/*
* Copyright (c) 2010 the original author or authors
*
* Permission is hereby granted to use, modify, and distribute this file
* in accordance with the terms of the license agreement accompanying it.
*/
package org.tinytlf.interaction.gesture.behaviors
{
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.text.engine.TextBlock;
    import flash.text.engine.TextLine;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.gesture.GestureEvent;
    import org.tinytlf.gesture.behaviors.Behavior;
    import org.tinytlf.interaction.EventLineInfo;
    import org.tinytlf.utils.FTEUtil;
    
    import spark.primitives.Line;

    public class CharacterSelectionBehavior extends Behavior
    {
        private var selectionBeginIndex:int = 0;
        
        override protected function onMouseDown(m:MouseEvent):void
        {
            super.onMouseDown(m);
            
            var info:EventLineInfo = EventLineInfo.getInfo(m);
            
            if(!info)
                return;
            
            var engine:ITextEngine = info.engine;
            var line:TextLine = info.line;
            var blockPosition:int = engine.getBlockPosition(line.textBlock);
            var m:MouseEvent = MouseEvent(info.event);
            
            var atomIndex:int = FTEUtil.getAtomIndexAtPoint(line, m.stageX, m.stageY);
            if(atomIndex < 0)
                return;
            
            engine.select();
            selectionBeginIndex = line.getAtomTextBlockBeginIndex(Math.min(atomIndex, line.atomCount - 1)) + blockPosition;
            engine.caretIndex = selectionBeginIndex;
        }
        
        override protected function onMouseUp(event:MouseEvent):void
        {
            super.onMouseUp(event);
            
            selectionBeginIndex = 0;
        }
        
        override protected function onMouseMove(m:MouseEvent):void
        {
            super.onMouseMove(m);
            
            if(!m.buttonDown)
                return;
            
            var info:EventLineInfo = EventLineInfo.getInfo(m);
            
            if(!info)
                return;
            
            var engine:ITextEngine = info.engine;
            var line:TextLine = info.line;
            var block:TextBlock = line.textBlock;
            var selection:Point = engine.selection.clone();
            var m:MouseEvent = MouseEvent(info.event);
            var atomIndex:int = FTEUtil.getAtomIndexAtPoint(line, m.stageX, m.stageY);
            
            if(atomIndex < 0)
                return;
            
            atomIndex = line.getAtomTextBlockBeginIndex(Math.min(atomIndex, line.atomCount - 1)) + engine.getBlockPosition(block);
            var caretIndex:int = engine.caretIndex;
            
            if(isNaN(selection.x))
                selection.x = selectionBeginIndex;
            if(isNaN(selection.y))
                selection.y = selectionBeginIndex;
            
            if(atomIndex < selectionBeginIndex)
            {
                selection.x = atomIndex;
                selection.y = selectionBeginIndex - 1;
                caretIndex = atomIndex;
            }
            else if(atomIndex > selectionBeginIndex)
            {
                selection.x = selectionBeginIndex;
                selection.y = atomIndex - 1;
                caretIndex = atomIndex;
            }
            else
            {
                selection.x = NaN;
                selection.y = NaN;
                caretIndex = atomIndex;
            }
            
            engine.select(selection.x, selection.y);
            engine.caretIndex = caretIndex;
        }
    }
}