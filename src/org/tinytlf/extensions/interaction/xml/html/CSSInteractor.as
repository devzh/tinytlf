package org.tinytlf.extensions.interaction.xml.html
{
    import flash.events.MouseEvent;
    import flash.text.engine.ContentElement;
    import flash.text.engine.ElementFormat;
    import flash.ui.Mouse;
    import flash.ui.MouseCursor;
    
    import org.tinytlf.ITextEngine;
    import org.tinytlf.TextDispatcherBase;
    import org.tinytlf.decor.ITextDecor;
    import org.tinytlf.interaction.EventLineInfo;
    import org.tinytlf.styles.ITextStyler;
    import org.tinytlf.utils.FTEUtil;

    public class CSSInteractor extends TextDispatcherBase
    {
        override protected function onClick(event:MouseEvent):void
        {
            super.onClick(event);
            
            var info:EventLineInfo = EventLineInfo.getInfo(event, this);
            applyCSSFormatting(info, 'visited');
            applyCSSDecorations(info, 'visited');
            applyCursor(info, 'hover');
        }

        override protected function onRollOver(event:MouseEvent):void
        {
            super.onRollOver(event);
            
            var info:EventLineInfo = EventLineInfo.getInfo(event, this);
            applyCSSFormatting(info, 'hover');
            applyCSSDecorations(info, 'hover');
            applyCursor(info, 'hover');
        }
        
        override protected function onMouseMove(event:MouseEvent):void
        {
            super.onMouseMove(event);
            
            var info:EventLineInfo = EventLineInfo.getInfo(event, this);
            applyCursor(info, 'hover');
        }
        
        override protected function onMouseUp(event:MouseEvent):void
        {
            super.onMouseUp(event);
            
            var info:EventLineInfo = EventLineInfo.getInfo(event, this);
            applyCursor(info, 'hover');
        }

        override protected function onRollOut(event:MouseEvent):void
        {
            super.onRollOut(event);
            
            var info:EventLineInfo = EventLineInfo.getInfo(event, this);
            repealCSSFormatting(info);
            repealCSSDecorations(info, 'hover');
            applyCursor(info);
        }

        override protected function onMouseDown(event:MouseEvent):void
        {
            super.onMouseDown(event);
            
            var info:EventLineInfo = EventLineInfo.getInfo(event, this);
            applyCSSFormatting(info, 'active');
            applyCSSDecorations(info, 'active');
            applyCursor(info, 'hover');
        }
        
        protected function applyCSSDecorations(info:EventLineInfo, state:String):void
        {
            var attr:Object = resolveCSSAttributes(info, state);
            var engine:ITextEngine = info.engine;
            
            if(attr)
                engine.decor.decorate(info.element, attr);
        }
        
        protected function repealCSSDecorations(info:EventLineInfo, state:String):void
        {
            var element:ContentElement = info.element;
            var decor:ITextDecor = info.engine.decor;
            
            var attr:Object = resolveCSSAttributes(info, state);
            
            for(var prop:String in attr)
                decor.undecorate(element, prop);
        }
        
        protected function applyCSSFormatting(info:EventLineInfo, state:String):void
        {
            var element:ContentElement = info.element;
            var tree:Array = (element.userData as Array);
            if(!tree)
                return;
            
            var styler:ITextStyler = info.engine.styler;
            var a:Array = applyStateToAncestorChain(tree, state);
            var format:ElementFormat = styler.getElementFormat(a);
            
            if(FTEUtil.compare(element.elementFormat.clone(), format))
            {
                element.elementFormat = format;
                info.engine.invalidateLines();
            }
        }
        
        protected function repealCSSFormatting(info:EventLineInfo):void
        {
            var element:ContentElement = info.element;
            var tree:Array = (element.userData as Array);
            if(!tree)
                return;
            
            var styler:ITextStyler = info.engine.styler;
            var format:ElementFormat = styler.getElementFormat(tree);
            
            if(FTEUtil.compare(element.elementFormat.clone(), format))
            {
                element.elementFormat = format;
                info.engine.invalidateLines();
            }
        }
        
        protected function applyCursor(info:EventLineInfo, state:String = ''):void
        {
            var attr:Object = resolveCSSAttributes(info, state);
            if('cursor' in attr)
                Mouse.cursor = attr['cursor'];
            else
                Mouse.cursor = MouseCursor.IBEAM;
        }
        
        protected var stateCache:Object = {};

        protected function resolveCSSAttributes(info:EventLineInfo, state:String):Object
        {
            if(state in stateCache)
                return stateCache[state];
            
            var tree:Array = (info.element.userData as Array);
            
            if(!tree)
                return {};
            
            return stateCache[state] = info.engine.styler.describeElement(applyStateToAncestorChain(tree, state));
        }
        
        protected function applyStateToAncestorChain(chain:Array, state:String):Array
        {
            var chainStr:String = chain.toString() + state;
            
            if(chainStr in stateCache)
                return stateCache[chainStr];
            
            var a:Array = [];
            var n:int = chain.length;
            var xml:XML;
            
            for(var i:int = 0; i < n; ++i)
            {
                xml = new XML(chain[i]);
                xml.@cssState = state;
                a.push(xml);
            }
            
            stateCache[chainStr] = a;
            
            return a;
        }
    }
}