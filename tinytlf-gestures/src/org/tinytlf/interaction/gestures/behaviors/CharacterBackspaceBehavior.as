package org.tinytlf.interaction.gestures.behaviors
{
    import flash.events.KeyboardEvent;
    import flash.text.engine.ContentElement;
    import flash.text.engine.GroupElement;
    import flash.text.engine.TextElement;
    
    import org.tinytlf.ITextEngine;
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
            var element:ContentElement = info.element;
            var caretIndex:int = engine.caretIndex;
            var blockPosition:int = engine.getBlockPosition(info.line.textBlock);
            
			var localIndex:int = caretIndex - blockPosition - element.textBlockBeginIndex;
			if(element is TextElement)
			{
				TextElement(element).replaceText(localIndex - 1, localIndex, null);
				engine.caretIndex--;
	            engine.invalidate();
			}
        }
    }
}