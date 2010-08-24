package org.tinytlf.interaction.xhtml
{
	import flash.events.MouseEvent;
	import flash.text.engine.ContentElement;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.decor.ITextDecor;
	import org.tinytlf.interaction.EventLineInfo;
	import org.tinytlf.interaction.TextDispatcherBase;
	import org.tinytlf.styles.ITextStyler;
	import org.tinytlf.util.TinytlfUtil;
	import org.tinytlf.util.XMLUtil;
	
	public class CSSInteractor extends TextDispatcherBase
	{
		protected var cssState:String = '';
		
		protected static const ACTIVE:String = 'active';
		protected static const HOVER:String = 'hover';
		protected static const VISITED:String = 'visited';
		
		override protected function onClick(event:MouseEvent):void
		{
			super.onClick(event);
			
			var info:EventLineInfo = EventLineInfo.getInfo(event, this);
			if (!info)
				return;
			
			applyCSSFormatting(info, VISITED);
			applyCSSDecorations(info, VISITED);
			applyCursor(info, HOVER);
		}
		
		override protected function onRollOver(event:MouseEvent):void
		{
			if (TinytlfUtil.isBitSet(mouseState, OVER))
				return;
			
			super.onRollOver(event);
			
			var info:EventLineInfo = EventLineInfo.getInfo(event, this);
			if (!info)
				return;
			
			cssState = cssState == VISITED ? VISITED : HOVER;
			
			applyCSSFormatting(info, cssState);
			applyCSSDecorations(info, cssState);
			applyCursor(info, HOVER);
		}
		
		override protected function onRollOut(event:MouseEvent):void
		{
			super.onRollOut(event);
			
			if (cssState == ACTIVE)
				cssState = VISITED;
			
			var info:EventLineInfo = EventLineInfo.getInfo(event, this);
			if (!info)
				return;
			
			if (cssState != VISITED)
				repealCSSFormatting(info);
			
			repealCSSDecorations(info, cssState);
			
			cssState = cssState == VISITED ? VISITED : '';
			
			applyCSSFormatting(info, cssState);
			applyCSSDecorations(info, cssState);
			applyCursor(info);
		}
		
		override protected function onMouseMove(event:MouseEvent):void
		{
			if (!TinytlfUtil.isBitSet(mouseState, OVER))
				return;
			
			super.onMouseMove(event);
			
			var info:EventLineInfo = EventLineInfo.getInfo(event, this);
			if (!info)
				return;
			
			cssState = cssState == VISITED ? VISITED : cssState == ACTIVE ? ACTIVE : HOVER;
			
			applyCursor(info, HOVER);
		}
		
		override protected function onMouseUp(event:MouseEvent):void
		{
			super.onMouseUp(event);
			
			var info:EventLineInfo = EventLineInfo.getInfo(event, this);
			if (!info)
				return;
			
			cssState = VISITED;
			
			applyCSSFormatting(info, cssState);
			applyCSSDecorations(info, cssState);
			applyCursor(info, HOVER);
		}
		
		override protected function onMouseDown(event:MouseEvent):void
		{
			super.onMouseDown(event);
			
			var info:EventLineInfo = EventLineInfo.getInfo(event, this);
			if (!info)
				return;
			
			cssState = ACTIVE;
			
			applyCSSFormatting(info, cssState);
			applyCSSDecorations(info, cssState);
			applyCursor(info, HOVER);
		}
		
		protected function applyCSSDecorations(info:EventLineInfo, state:String = ''):void
		{
			var attr:Object = resolveCSSAttributes(info, state);
			var engine:ITextEngine = info.engine;
			
			if (attr)
				engine.decor.decorate(info.element, attr);
		}
		
		protected function repealCSSDecorations(info:EventLineInfo, state:String = ''):void
		{
			var element:ContentElement = info.element;
			var decor:ITextDecor = info.engine.decor;
			
			var attr:Object = resolveCSSAttributes(info, state);
			
			for (var prop:String in attr)
				decor.undecorate(element, prop);
		}
		
		protected function applyCSSFormatting(info:EventLineInfo, state:String):void
		{
			var element:ContentElement = info.element;
			var tree:Array = (element.userData as Array);
			if (!tree)
				return;
			
			var styler:ITextStyler = info.engine.styler;
			var a:Array = applyStateToAncestorChain(tree, state);
			element.elementFormat = styler.getElementFormat(a).clone();
			info.engine.invalidateLines();
		}
		
		protected function repealCSSFormatting(info:EventLineInfo):void
		{
			var element:ContentElement = info.element;
			var tree:Array = (element.userData as Array);
			if (!tree)
				return;
			
			var styler:ITextStyler = info.engine.styler;
			element.elementFormat = styler.getElementFormat(tree).clone();
			info.engine.invalidateLines();
		}
		
		protected function applyCursor(info:EventLineInfo, state:String = ''):void
		{
			var attr:Object = resolveCSSAttributes(info, state);
			if ('cursor' in attr)
				Mouse.cursor = attr['cursor'];
			else
				Mouse.cursor = MouseCursor.IBEAM;
		}
		
		protected var stateCache:Object = {};
		
		protected function resolveCSSAttributes(info:EventLineInfo, state:String):Object
		{
			if (state && state in stateCache)
				return stateCache[state];
			
			var tree:Array = (info.element.userData as Array);
			
			if (!tree)
				return {};
			
			var style:Object = info.engine.styler.describeElement(applyStateToAncestorChain(tree, state));
			
			if (state && style)
				stateCache[state] = style
			
			return style;
		}
		
		protected function applyStateToAncestorChain(chain:Array, state:String):Array
		{
			var chainStr:String = XMLUtil.arrayToString(chain) + ':' + state;
			
			if (chainStr in stateCache)
				return stateCache[chainStr];
			
			var a:Array = [];
			var n:int = chain.length;
			var xml:XML;
			
			for (var i:int = 0; i < n; ++i)
			{
				xml = new XML(XMLUtil.toCamelCase(chain[i].toXMLString()));
				xml.@cssState = state;
				a.push(xml);
			}
			
			stateCache[chainStr] = a;
			
			return a;
		}
	}
}