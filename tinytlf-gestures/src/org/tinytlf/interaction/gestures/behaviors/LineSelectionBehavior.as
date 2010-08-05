package org.tinytlf.interaction.gestures.behaviors
{
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.text.engine.TextBlock;
    import flash.text.engine.TextLine;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.interaction.EventLineInfo;

    public class LineSelectionBehavior extends Behavior
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
            var begin:int = line.textBlockBeginIndex + blockPosition;
            var end:int = line.getAtomTextBlockBeginIndex(line.atomCount - 1) + blockPosition;
            
            selectionBegin.x = begin;
            selectionBegin.y = end;
            
            engine.select(begin, end);
            engine.caretIndex = end + 1;
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
            var caretIndex:int = engine.caretIndex;
            var blockPosition:int = engine.getBlockPosition(block);
            
            var begin:int = line.textBlockBeginIndex + blockPosition;
            var end:int = line.getAtomTextBlockBeginIndex(line.atomCount - 1) + blockPosition;
            
            if(begin < selectionBegin.x)
            {
                selection.x = begin;
                selection.y = selectionBegin.y;
                caretIndex = begin;
            }
            else if(begin > selectionBegin.y)
            {
                selection.x = selectionBegin.x;
                selection.y = end;
                caretIndex = end + 1;
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