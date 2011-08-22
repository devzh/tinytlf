package org.tinytlf.style
{
	import flash.text.engine.*;
	
	import org.tinytlf.*;
	import org.tinytlf.html.*;
	
	public class DOMEFFactory implements IElementFormatFactory
	{
		public function getElementFormat(item:Object):ElementFormat
		{
			const dom:DOMNode = item as DOMNode;
			if(!dom)
				return new ElementFormat();
			
			const fd:FontDescription = new FontDescription();
			
			fd.cffHinting = tryBoth(dom, 'cff', 'hinting') || CFFHinting.HORIZONTAL_STEM;
			fd.fontLookup = tryBoth(dom, 'font', 'lookup') || FontLookup.EMBEDDED_CFF;
			fd.fontName = tryBoth(dom, 'font', 'name') || tryBoth(dom, 'font', 'family') || '_sans';
			fd.fontPosture = tryBoth(dom, 'font', 'style') == FontPosture.ITALIC ? FontPosture.ITALIC : FontPosture.NORMAL;
			fd.fontPosture = tryBoth(dom, 'font', 'posture') || fd.fontPosture;
			fd.fontWeight = tryBoth(dom, 'font', 'weight') || FontWeight.NORMAL;
			fd.renderingMode = tryBoth(dom, 'rendering', 'mode') || RenderingMode.CFF;
			
			const ef:ElementFormat = new ElementFormat(fd);
			ef.alignmentBaseline = tryBoth(dom, 'alignment', 'baseline') || TextBaseline.USE_DOMINANT_BASELINE;
			ef.alpha = valueFilter(dom.alpha || '1', 'number');
			ef.baselineShift = valueFilter(tryBoth(dom, 'baseline', 'shift') || '0', 'number');
			ef.breakOpportunity = dom.tryBoth(dom, 'break', 'opportunity') || BreakOpportunity.AUTO;
			ef.color = valueFilter(dom.color || '0x00', 'uint');
			ef.digitCase = tryBoth(dom, 'digit', 'case') || DigitCase.DEFAULT;
			ef.digitWidth = tryBoth(dom, 'digit', 'width') || DigitWidth.DEFAULT;
			ef.dominantBaseline = dom.tryBoth(dom, 'dominant', 'baseline') || TextBaseline.ROMAN;
			ef.fontSize = valueFilter(dom.tryBoth(dom, 'font', 'size') || '12', 'number');
			ef.kerning = dom.kerning || Kerning.AUTO;
			ef.ligatureLevel = dom.tryBoth(dom, 'ligature', 'level') || LigatureLevel.COMMON;
			ef.locale = dom.locale || 'en_US';
			ef.textRotation = dom.tryBoth(dom, 'text', 'rotation') || TextRotation.AUTO;
			ef.trackingLeft = valueFilter(dom.tryBoth(dom, 'tracking', 'left') || '0', 'number');
			ef.trackingRight = valueFilter(dom.tryBoth(dom, 'tracking', 'right') || '0', 'number');
			ef.typographicCase = dom.tryBoth(dom, 'typographic', 'case') || TypographicCase.DEFAULT;
			
			return ef;
		}
		
		private function valueFilter(value:String, type:String):*
		{
			return conversionMap.hasOwnProperty(type) ? conversionMap[type](value) : value;
		}
		
		private function tryBoth(obj:Object, ... props):*
		{
			var str:String = '';
			props.
				forEach(function(part:String, i:int, ... args):void {
					if(i > 0)
						part = part.charAt(0).toUpperCase() + part.substr(1);
					str += part;
				});
			
			if(obj.hasOwnProperty(str))
				return obj[str];
			
			str = '';
			props.
				forEach(function(part:String, i:int, a:Array):void {
					if(i != a.length - 1)
						part += '-';
					
					str += part;
				});
			
			if(obj.hasOwnProperty(str))
				return obj[str];
			
			return null;
		}
		
		private static const conversionMap:Object = {
				'number': function(input:String):Number {return Number(input);},
				'boolean': function(input:String):Number {return Boolean(input);},
				'uint': function(input:String):Number {return uint(input);}
			};
	}
}
