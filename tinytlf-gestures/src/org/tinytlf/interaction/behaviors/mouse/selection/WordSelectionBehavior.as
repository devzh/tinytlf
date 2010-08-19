package org.tinytlf.interaction.behaviors.mouse.selection
{
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.text.engine.TextBlock;
    import flash.text.engine.TextLine;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.interaction.EventLineInfo;
    import org.tinytlf.interaction.behaviors.Behavior;
    import org.tinytlf.util.TinytlfUtil;
    import org.tinytlf.util.fte.TextLineUtil;

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
			var atomIndex:int = TextLineUtil.getAtomIndexAtPoint(line, new Point(event.stageX, event.stageY));
            
            var begin:int = TextLineUtil.getAtomWordBoundary(line, atomIndex);
			begin = TinytlfUtil.atomIndexToGlobalIndex(engine, line, begin);
			
            var end:int = TextLineUtil.getAtomWordBoundary(line, atomIndex, false);
			end = TinytlfUtil.atomIndexToGlobalIndex(engine, line, end);
            
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
            var atomIndex:int = TextLineUtil.getAtomIndexAtPoint(line, new Point(event.stageX, event.stageY));
            
            var caretIndex:int = engine.caretIndex;
            var globalIndex:int = TinytlfUtil.atomIndexToGlobalIndex(engine, line, atomIndex);
            
            if(globalIndex < selectionBegin.x)
            {
                selection.x = TinytlfUtil.atomIndexToGlobalIndex(engine, line,
					TextLineUtil.getAtomWordBoundary(line, atomIndex));
				
                selection.y = selectionBegin.y;
                caretIndex = selection.x;
            }
            else if(globalIndex > selectionBegin.y)
            {
                selection.x = selectionBegin.x;
                selection.y = TinytlfUtil.atomIndexToGlobalIndex(engine, line,
					TextLineUtil.getAtomWordBoundary(line, atomIndex, false));
				
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