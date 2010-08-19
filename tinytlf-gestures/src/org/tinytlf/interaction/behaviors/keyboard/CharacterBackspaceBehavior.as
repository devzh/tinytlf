package org.tinytlf.interaction.behaviors.keyboard
{
    import flash.events.KeyboardEvent;
    import flash.text.engine.ContentElement;
    import flash.text.engine.TextElement;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.interaction.EventLineInfo;
    import org.tinytlf.interaction.behaviors.Behavior;
    import org.tinytlf.util.TinytlfUtil;
    
	////
	//  This is just experimenting. All this model editing stuff should exist in
	//  its own special circle of tinytlf hell where the righteous classes don't
	//  have to translate indicies and handle out-of-bounds cases.
	////
	
    public class CharacterBackspaceBehavior extends Behavior
    {
        override protected function onKeyDown(event:KeyboardEvent):void
        {
            super.onKeyDown(event);
            
            var info:EventLineInfo = EventLineInfo.getInfo(event);
            
            if(!info)
                return;
            
			var engine:ITextEngine = info.engine;
			var caretIndex:int = engine.caretIndex;
            var element:ContentElement = TinytlfUtil.caretIndexToContentElement(engine);
			var localIndex:int = TinytlfUtil.caretIndexToContentElementIndex(engine, element);
			
			if(element is TextElement)
			{
				while(localIndex == 0)
				{
					element = TinytlfUtil.globalIndexToContentElement(engine, --caretIndex);
					localIndex = TinytlfUtil.globalIndexToContentElementIndex(engine, caretIndex, element);
				}
				
				TextElement(element).replaceText(localIndex - 1, localIndex, null);
				engine.caretIndex--;
	            engine.invalidate();
			}
        }
    }
}