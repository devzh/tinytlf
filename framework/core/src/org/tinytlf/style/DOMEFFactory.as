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
			
			fd.cffHinting = dom.cffHinting || CFFHinting.HORIZONTAL_STEM;
			fd.fontLookup = dom.fontLookup || FontLookup.EMBEDDED_CFF;
			fd.fontName = dom.fontName || dom.fontFamily || '_sans';
			fd.fontPosture = dom.fontStyle == FontPosture.ITALIC ? FontPosture.ITALIC : FontPosture.NORMAL;
			fd.fontPosture = dom.fontPosture || fd.fontPosture;
			fd.fontWeight = dom.fontWeight || FontWeight.NORMAL;
			fd.renderingMode = dom.renderingMode || RenderingMode.CFF;
			
			const ef:ElementFormat = new ElementFormat(fd);
			ef.alignmentBaseline = dom.alignmentBaseline || TextBaseline.USE_DOMINANT_BASELINE;
			ef.alpha = valueFilter(dom.alpha || '1', 'number');
			ef.baselineShift = valueFilter(dom.baselineShift || '0', 'number');
			ef.breakOpportunity = dom.breakOpportunity || BreakOpportunity.AUTO;
			ef.color = valueFilter(dom.color || '0x00', 'uint');
			ef.digitCase = dom.digitCase || DigitCase.DEFAULT;
			ef.digitWidth = dom.digitWidth || DigitWidth.DEFAULT;
			ef.dominantBaseline = dom.dominantBaseline || TextBaseline.ROMAN;
			ef.fontSize = valueFilter(dom.fontSize || '12', 'number');
			ef.kerning = dom.kerning || Kerning.AUTO;
			ef.ligatureLevel = dom.ligatureLevel || LigatureLevel.COMMON;
			ef.locale = dom.locale || 'en_US';
			ef.textRotation = dom.textRotation || TextRotation.AUTO;
			ef.trackingLeft = valueFilter(dom.trackingLeft || '0', 'number');
			ef.trackingRight = valueFilter(dom.trackingRight || '0', 'number');
			ef.typographicCase = dom.typographicCase || TypographicCase.DEFAULT;
			
			return ef;
		}
		
		private function valueFilter(value:String, type:String):*
		{
			return conversionMap.hasOwnProperty(type) ? conversionMap[type](value) : value;
		}
		
		private static const conversionMap:Object = {
				'number': function(input:String):Number {return Number(input);},
				'boolean': function(input:String):Number {return Boolean(input);},
				'uint': function(input:String):Number {return uint(input);}
			};
	}
}
