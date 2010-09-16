/*
* Copyright (c) 2010 the original author or authors
*
* Permission is hereby granted to use, modify, and distribute this file
* in accordance with the terms of the license agreement accompanying it.
*/
package org.tinytlf.interaction.behaviors.mouse.selection
{
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.text.engine.TextLine;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.interaction.EventLineInfo;
    import org.tinytlf.interaction.behaviors.Behavior;
    import org.tinytlf.util.TinytlfUtil;
    import org.tinytlf.util.fte.TextLineUtil;

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
            
            engine.select();
			
			selectionBeginIndex = TinytlfUtil.atomIndexToGlobalIndex(engine, line, 
				TextLineUtil.getAtomIndexAtPoint(line, new Point(m.stageX, m.stageY)));
			
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
            var selection:Point = engine.selection.clone();
            var index:int = TextLineUtil.getAtomIndexAtPoint(line, new Point(m.stageX, m.stageY));
			
            var atomIndex:int = TinytlfUtil.atomIndexToGlobalIndex(engine, line, index);
			
            var caretIndex:int = engine.caretIndex;
            
            if(selection.x != selection.x)
                selection.x = selectionBeginIndex;
			
            if(selection.y != selection.y)
                selection.y = selectionBeginIndex;
			
			var atomSide:Boolean = TextLineUtil.getAtomSide(line, new Point(m.stageX, m.stageY));
			
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