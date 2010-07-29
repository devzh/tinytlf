package org.tinytlf.extensions.interaction.xml.html
{
    import flash.events.MouseEvent;
    import flash.events.TextEvent;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    
    import org.tinytlf.interaction.EventLineInfo;
    import org.tinytlf.utils.XMLUtil;

    public class AnchorInteractor extends CSSInteractor
    {
        override protected function onMouseUp(event:MouseEvent):void
        {
            var info:EventLineInfo = EventLineInfo.getInfo(event, this);
            if(!info)
                return;
            
            var tree:Array = (info.element.userData as Array);
            if(!tree || !tree.length)
                return;
            
            var link:Object = XMLUtil.buildKeyValueAttributes(tree.concat().pop().attributes());
            var href:String = link['href'];
            
            //If there's an href, launch the URL. Otherwise, dispatch an event from this TextLine.
            if(href)
                navigateToURL(new URLRequest(href), link['target'] || '_blank');
            else
                info.line.dispatchEvent(new TextEvent(TextEvent.LINK, true, false, info.element.text));
            
            super.onMouseUp(event);
        }
    }
}