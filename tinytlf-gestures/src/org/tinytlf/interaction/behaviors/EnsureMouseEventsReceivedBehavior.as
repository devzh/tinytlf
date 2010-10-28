package org.tinytlf.interaction.behaviors
{
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.text.engine.TextLine;
    import flash.text.engine.TextLineMirrorRegion;
    
    import org.tinytlf.interaction.EventLineInfo;
    
    public class EnsureMouseEventsReceivedBehavior extends Behavior
    {
        public function EnsureMouseEventsReceivedBehavior()
        {
            super();
        }
        
        override protected function onRollOut(event:MouseEvent):void
        {
            if(dispatchedHere)
                return;
            
            super.onRollOut(event);
            checkEvent(event);
        }
        
        override protected function onRollOver(event:MouseEvent):void
        {
            if(dispatchedHere)
                return;
            
            super.onRollOver(event);
            checkEvent(event);
        }
        
        private var dispatchedHere:Boolean = false;
        
        private function checkEvent(event:MouseEvent):void
        {
            var info:EventLineInfo = EventLineInfo.getInfo(event);
            if(!info)
                return;
            
            var line:TextLine = info.line;
            var coords:Point = line.globalToLocal(new Point(event.stageX, event.stageY));
            
            for each(var tlmr:TextLineMirrorRegion in line.mirrorRegions)
            {
                if(tlmr.bounds.contains(coords.x, tlmr.bounds.y + 1))
                {
                    dispatchedHere = true;
                    
                    line.dispatchEvent(new MouseEvent(event.type, true, false, 
                        coords.x, tlmr.bounds.y + 1, line, 
                        event.ctrlKey, event.altKey, event.shiftKey,
                        event.buttonDown, event.delta));
                    
                    dispatchedHere = false;
                }
            }
        }
    }
}