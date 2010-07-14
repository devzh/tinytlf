package org.tinytlf.interaction.gesture.behaviors
{
    import flash.events.KeyboardEvent;
    import flash.text.engine.ContentElement;
    import flash.text.engine.GroupElement;
    import flash.text.engine.TextElement;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.gesture.behaviors.Behavior;
    import org.tinytlf.interaction.EventLineInfo;
    
    public class CharacterBackspaceBehavior extends Behavior
    {
        override protected function onKeyDown(event:KeyboardEvent):void
        {
            super.onKeyDown(event);
            
            var info:EventLineInfo = EventLineInfo.getInfo(event);
            
            if(!info)
                return;
            
            var engine:ITextEngine = info.engine;
            var element:GroupElement = info.element.groupElement;
            var caretIndex:int = engine.caretIndex;
            var blockPosition:int = engine.getBlockPosition(info.line.textBlock);
            
            caretIndex -= blockPosition - element.textBlockBeginIndex;
            element.replaceElements(caretIndex, caretIndex, null);
            engine.invalidate();
        }
    }
}