package org.tinytlf.interaction.gestures.behaviors.keyboard
{
    import flash.events.KeyboardEvent;
    import flash.text.engine.ContentElement;
    import flash.text.engine.GroupElement;
    import flash.text.engine.TextBlock;
    import flash.text.engine.TextElement;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.interaction.EventLineInfo;
    import org.tinytlf.interaction.gestures.behaviors.Behavior;
    import org.tinytlf.util.FTEUtil;
    
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
			var block:TextBlock = info.line.textBlock;
            var caretIndex:int = engine.caretIndex;
            var blockPosition:int = engine.getBlockPosition(block);
			var blockIndex:int = caretIndex - blockPosition;
            var element:ContentElement = FTEUtil.getContentElementAt(block.content, blockIndex);
            
			var localIndex:int = blockIndex - element.textBlockBeginIndex;
			if(element is TextElement)
			{
				while(localIndex == 0)
				{
					element = FTEUtil.getContentElementAt(block.content, blockIndex - 1);
					localIndex = blockIndex - element.textBlockBeginIndex;
				}
				
				TextElement(element).replaceText(localIndex - 1, localIndex, null);
				engine.caretIndex--;
	            engine.invalidate();
			}
        }
    }
}