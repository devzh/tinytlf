/*
* Copyright (c) 2010 the original author or authors
*
* Permission is hereby granted to use, modify, and distribute this file
* in accordance with the terms of the license agreement accompanying it.
*/
package org.tinytlf.interaction.behaviors
{
    import flash.display.Stage;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    
    import org.tinytlf.interaction.EventLineInfo;
    
    public class FocusBehavior extends Behavior
    {
        override protected function onKeyDown(event:KeyboardEvent):void
        {
            super.onKeyDown(event);
            
            var info:EventLineInfo = EventLineInfo.getInfo(event);
            
            if(!info)
                return;
            
            info.line.stage.focus = info.line;
        }
        
        override protected function onMouseDown(event:MouseEvent):void
        {
            super.onMouseDown(event);
            
            var info:EventLineInfo = EventLineInfo.getInfo(event);
            
            if(!info)
                return;
            
            info.line.stage.focus = info.line;
        }
        
        override protected function onMouseMove(event:MouseEvent):void
        {
            super.onMouseMove(event);
            
            if(!event.buttonDown)
                return;
            
            var info:EventLineInfo = EventLineInfo.getInfo(event);
            
            if(!info)
                return;
            
            info.line.stage.focus = info.line;
        }
    }
}