/*
* Copyright (c) 2010 the original author or authors
*
* Permission is hereby granted to use, modify, and distribute this file
* in accordance with the terms of the license agreement accompanying it.
*/
package org.tinytlf.interaction.gestures.behaviors.mouse.selection
{
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.text.engine.TextBlock;
    import flash.text.engine.TextLine;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.interaction.EventLineInfo;
    import org.tinytlf.util.FTEUtil;
    
    import spark.primitives.Line;
    import org.tinytlf.interaction.gestures.behaviors.Behavior;

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
            
            engine.select();
			
			selectionBeginIndex = line.textBlockBeginIndex + atomIndex + blockPosition;
			
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
            var index:int = FTEUtil.getAtomIndexAtPoint(line, m.stageX, m.stageY);
            
            var atomIndex:int = line.getAtomTextBlockBeginIndex(
				Math.min(index, line.atomCount - 1)) + engine.getBlockPosition(block);
			
            var caretIndex:int = engine.caretIndex;
            
            if(isNaN(selection.x))
                selection.x = selectionBeginIndex;
			
            if(isNaN(selection.y))
                selection.y = selectionBeginIndex;
			
			var atomSide:Boolean = FTEUtil.getAtomSide(line, m.stageX, m.stageY);
			
			var atEnd:Boolean = (index == line.atomCount);
            
            if(atomIndex < selectionBeginIndex && (!atEnd || atomSide))
            {
                selection.x = atomIndex;
                selection.y = selectionBeginIndex - 1;
                caretIndex = atomIndex;
            }
			else if(atomIndex > selectionBeginIndex)
			{
                selection.x = selectionBeginIndex;
				
                selection.y = atomIndex - (atEnd || atomSide ? 0 : 1);
                caretIndex = atomIndex + (atEnd || atomSide ? 1 : 0);
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