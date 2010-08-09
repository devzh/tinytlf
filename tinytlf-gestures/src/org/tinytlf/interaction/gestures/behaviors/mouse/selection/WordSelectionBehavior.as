package org.tinytlf.interaction.gestures.behaviors.mouse.selection
{
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.text.engine.TextBlock;
    import flash.text.engine.TextLine;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.interaction.EventLineInfo;
    import org.tinytlf.util.FTEUtil;
    import org.tinytlf.interaction.gestures.behaviors.Behavior;

    public class WordSelectionBehavior extends Behavior
    {
        private var selectionBegin:Point = new Point();
        
        override protected function onMouseDown(event:MouseEvent):void
        {
            super.onMouseDown(event);
            
            var info:EventLineInfo = EventLineInfo.getInfo(event);
            
            if(!info)
                return;
            
            var engine:ITextEngine = info.engine;
            var line:TextLine = info.line;
            var blockPosition:int = engine.getBlockPosition(line.textBlock);
            
            var atomIndex:int = line.getAtomIndexAtPoint(event.stageX, event.stageY);
            
            var begin:int = line.getAtomTextBlockBeginIndex(FTEUtil.getAtomWordBoundary(line, atomIndex)) + blockPosition;
            var end:int = line.getAtomTextBlockBeginIndex(FTEUtil.getAtomWordBoundary(line, atomIndex, false)) + blockPosition;
            
            selectionBegin.x = begin;
            selectionBegin.y = end;
            
            engine.caretIndex = end + 1;
            engine.select(begin, end);
        }
        
        override protected function onMouseUp(event:MouseEvent):void
        {
            super.onMouseUp(event);
            
            selectionBegin.x = 0;
            selectionBegin.y = 0;
        }
        
        override protected function onMouseMove(event:MouseEvent):void
        {
            super.onMouseMove(event);
            
            if(!event.buttonDown)
                return;
            
            var info:EventLineInfo = EventLineInfo.getInfo(event);
            
            if(!info)
                return;
            
            var engine:ITextEngine = info.engine;
            var line:TextLine = info.line;
            var block:TextBlock = line.textBlock;
            var selection:Point = engine.selection.clone();
            var atomIndex:int = FTEUtil.getAtomIndexAtPoint(line, event.stageX, event.stageY);
            
            var caretIndex:int = engine.caretIndex;
            var blockPosition:int = engine.getBlockPosition(block);
            var adjustedIndex:int = line.getAtomTextBlockBeginIndex(Math.min(atomIndex, line.atomCount - 1)) + blockPosition;
            
            if(adjustedIndex < selectionBegin.x)
            {
                selection.x = line.getAtomTextBlockBeginIndex(FTEUtil.getAtomWordBoundary(line, atomIndex)) + blockPosition;
                selection.y = selectionBegin.y;
                caretIndex = selection.x;
            }
            else if(adjustedIndex > selectionBegin.y)
            {
                selection.x = selectionBegin.x;
                selection.y = line.getAtomTextBlockBeginIndex(
					FTEUtil.getAtomWordBoundary(line, atomIndex, false)) + blockPosition;
                caretIndex = selection.y + 1;
            }
            else
            {
                selection.x = selectionBegin.x;
                selection.y = selectionBegin.y;
                caretIndex = selectionBegin.y + 1;
            }
            
            engine.select(selection.x, selection.y);
            engine.caretIndex = caretIndex;
        }
    }
}