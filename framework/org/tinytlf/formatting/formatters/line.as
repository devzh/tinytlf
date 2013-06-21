package org.tinytlf.formatting.formatters
{
	import asx.object.mergeSealed;
	
	import flash.text.engine.LineJustification;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextJustifier;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextRotation;
	
	import org.tinytlf.Element;
	import org.tinytlf.enum.TextAlign;
	import org.tinytlf.enum.TextBlockProgression;
	import org.tinytlf.enum.TextDirection;
	import org.tinytlf.formatting.traversal.enumerateInline;
	
	import raix.reactive.IObservable;

	/**
	 * @author ptaylor
	 */
	public function line(document:Element, textBlock:TextBlock):Function {
		
		const formatBox:Function = box(formatter, document);
		
		return function(element:Element,
						getPredicate:Function, /*(element, cache, layout):Function*/
						getEnumerable:Function, /*(startFactory, index):Function*/
						getLayout:Function,
						layout:Function,
						create:Function):IObservable /*<Element, Boolean>*/ {
			
			const firstLine:TextLine = textBlock.firstLine;
			const lastLine:TextLine = textBlock.firstLine;
			
			if(firstLine && lastLine) textBlock.releaseLines(firstLine, lastLine);
			
			textBlock.releaseLineCreationData();
			
			// Set up the TextBlock's block formatting properties. Don't give the
			// TextBlock a ContentElement, runs create their own ContentElements.
			
			const justification:String = element.textAlign == TextAlign.JUSTIFY ?
				LineJustification.ALL_BUT_LAST :
				LineJustification.UNJUSTIFIED;
			
			const justifier:TextJustifier = TextJustifier.getJustifierForLocale(element.locale);
			
			textBlock.textJustifier = TextJustifier(mergeSealed(justifier, element, {lineJustification: justification}));
			
			const progression:String = element.blockProgression;
			
			textBlock.lineRotation = progression == TextBlockProgression.TTB ?
				TextRotation.ROTATE_0 : progression == TextBlockProgression.LTR ?
				TextRotation.ROTATE_270 :
				TextRotation.ROTATE_90;
			
			// TODO: Tabulate bidi flips on the way down.
			textBlock.bidiLevel = element.direction == TextDirection.LTR ? 0 : 1;
			
			// Calculate some values we'll need for inline layouts.
			element.setStyle('space-width', getSpaceWidth(element, textBlock));
			// TODO: do we ever need this?
			// element.setStyle('tab-width', getTextWidth(element, textBlock, '\t'));
			
			return formatBox(element, getPredicate, enumerateInline(element), getLayout, layout, create);
		};
	}
}

import asx.array.first;
import asx.fn.I;
import asx.fn.callProperty;
import asx.fn.memoize;

import flash.system.Capabilities;
import flash.text.engine.ElementFormat;
import flash.text.engine.TextBlock;
import flash.text.engine.TextElement;
import flash.text.engine.TextLine;

import org.tinytlf.Element;
import org.tinytlf.formatting.configuration.inline.getInlineFormatter;
import org.tinytlf.formatting.traversal.enumerateInline;
import org.tinytlf.fte.toElementFormat;

import raix.reactive.IObservable;
import raix.reactive.Observable;

internal function formatter(document:Element, container:Element, predicateFactory:Function, getLayout:Function, layout:Function):Function {
	return function(element:Element):IObservable /*<Element, Boolean>*/ {
		
		if(element.displayed('none')) return Observable.value([element, true]);
		
		return getInlineFormatter(document, element)(
			element,
			predicateFactory,
			enumerateInline(element),
			getLayout,
			layout,
			callProperty('addTo', container)
		);
	}
}

internal const screenDPI:Number = Capabilities.screenDPI;

internal function getSpaceWidth(element:Element, textBlock:TextBlock):Number {
	// Unicode spaces are 1/4em, but can be adjusted based on letter-spacing and
	// justification. font size in pixels = x-em * font-size
	// 
	// TODO: If an inline container has 'text-align: justify', we might have
	// to layout the inline elements normally, create a TextBlock with dummy
	// GraphicElements, then re-layout the children with the space gaps the
	// TextBlock calculates. In that case, it may not be appropriate to
	// use the space width calculated here. Investigate.
	return element.fontSize * 0.25;
}

internal function getTextWidth(element:Element, textBlock:TextBlock, chars:String):Number {
	const format:ElementFormat = toElementFormat(element);
	const content:TextElement = new TextElement(chars, format);
	textBlock.content = content;
	const line:TextLine = textBlock.createTextLine(null, TextLine.MAX_LINE_WIDTH);
	return line.width;
};
