package org.tinytlf.formatting.formatters
{
	import asx.array.first;
	import asx.array.last;
	import asx.array.map;
	import asx.array.max;
	import asx.array.pluck;
	import asx.fn.I;
	import asx.fn.K;
	import asx.fn.distribute;
	import asx.fn.partial;
	import asx.number.sum;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.text.engine.BreakOpportunity;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	import flash.text.engine.TextLineCreationResult;
	import flash.text.engine.TextLineValidity;
	
	import org.tinytlf.Edge;
	import org.tinytlf.Element;
	import org.tinytlf.enum.TextAlign;
	import org.tinytlf.fte.toElementFormat;
	import org.tinytlf.xml.keyToElement;
	
	import raix.reactive.IObservable;
	import raix.reactive.Observable;
	import raix.reactive.toObservable;
	
	import starling.display.Image;
	import starling.textures.Texture;
	
	/**
	 * @author ptaylor
	 */
	public function run(document:Element, textBlock:TextBlock):Function {
		
		var renderedWidth:Number = 0;
		var renderedTextIndent:Number = 0;
		var renderedContent:String = '';
		
		return function(element:Element,
						getStart:Function, /*(element, cache, layout):Function*/
						getEnumerator:Function, /*(startFactory, index):Function*/
						getLayout:Function,
						layout:Function,
						create:Function):IObservable /*<Element, Boolean>*/ {
			
			const text:String = element.text;
			
			if(layout != null) layout(element, false, false);
			
			const bounds:Edge = element.bounds();
			const lines:Array = element.hasStyle('lines') ? element.getStyle('lines') : [];
			
			if( bounds.width == renderedWidth &&
				text == renderedContent &&
				element.textIndent == renderedTextIndent) {
				
				return toObservable(map(lines, distribute(I, K(true)))).
					peek(null, partial(layout, element, true, false));
			}
			
			lines.length = 0;
			
			// I shouldn't be making TextLines in the formatting pass, but since
			// Flash is responsible for line breaking, I don't know where line
			// breaks are until the block is rendered. Since I've got to render
			// TextLines anyway, store them on the element and the renderer can read
			// them out and flatten them into a bitmap later.
			
			// I could do the TextLine creation/iteration stuff in
			// IObservable.scan, but honestly, who has the time.
			var previousLine:TextLine = null;
			
			const leading:Number = element.leading;
			const textAlign:Number = element.textAlign;
			
			const format:ElementFormat = toElementFormat(element);
			const content:TextElement = new TextElement(text, format /* TODO: support inline character rotation. */);
			
			textBlock.content = content;
			
			return Observable.generate(iterate(element), predicate, iterate, resultMap);//.
				// Skip the last value. The TextBlock doesn't change its
				// 'textLineCreationResult' flag to 'complete' until after it
				// returns 'null' from the last call to re/createTextLine. We're
				// forced to catch that case, finalize the containing <text/>
				// element, and re-dispatch the last successful line rendered.
				// skipLast(1);
			
			function predicate(element:Element):Boolean {
				return textBlock.textLineCreationResult != TextLineCreationResult.COMPLETE;
			};
			
			function iterate(prev:Element):Element {
				if(textBlock.textLineCreationResult == TextLineCreationResult.COMPLETE)
					return null;
				
				const key:String = element.key + (
					prev == element ?
					' line:0' :
					' line:' + (prev.index + 1));
				
				const lineElement:Element = keyToElement(key);
				
				lineElement.node = <line></line>;
				lineElement.key = key;
				lineElement.index = prev == element ? 0 : prev.index + 1;
				lineElement.setStyle('clear', textAlign == TextAlign.RIGHT ? 'left' : 'right');
				
				return lineElement;
			};
			
			function resultMap(lineElement:Element):Array {
				
				if(layout != null) layout(lineElement, false, false);
				
				const indent:Number = element.index == 0 ? element.textIndent : 0;
				const width:Number = lineElement.inside().width - indent;
				
				var line:TextLine = staticLine ?
					textBlock.recreateTextLine(staticLine, previousLine, width, 0.0, true) :
					textBlock.createTextLine(previousLine, width, 0.0, true);
				
				if(line) {
					// Only break whole words. Keep increasing the available width
					// for breaking until we've broken the next word.
					var emergencyBreakWidth:Number = line.width;
					while(textBlock.textLineCreationResult == TextLineCreationResult.EMERGENCY) {
						line = textBlock.recreateTextLine(line, previousLine, ++emergencyBreakWidth, 0.0, true);
						if(line == null) break;
					}
				}
				
				return line ?
					renderLineElement(lineElement, line, width) :
					// If no line was created, we've broken all the lines from this
					// TextBlock. Finalize and return the run element.
					finalizeRun(lineElement);
			};
			
			function renderLineElement(lineElement:Element, textLine:TextLine, width:Number):Array {
				
				// Be sure to render the entire TextLine if the lineHeight is
				// shorter than the textHeight, otherwise BitmapData.draw will cut
				// off the top and bottom of the TextLine.
				// 
				// TODO in layout: position the TextLine based on the vertical-align
				// CSS property.
				
				const textHeight:Number = Math.ceil(textLine.totalHeight);
				const lineHeight:Number = Math.ceil(element.lineHeight)
				const renderHeight:Number = Math.max(textHeight, lineHeight);
				
				// TODO: Do something if the line height is less than the render height.
				// const renderOffset:Number = (lineHeight - renderHeight) * 0.5;
				// lineElement.move(lineElement.x, lineElement.y - renderOffset);
				
				const bmd:BitmapData = new BitmapData(Math.ceil(textLine.width), Math.ceil(renderHeight), true, 0);
				
				matrix.createBox(1, 1, 0, 0, Math.round(textLine.ascent));
				bmd.draw(textLine, matrix);
				
				lineElement.setStyle('line', new Image(Texture.fromBitmapData(bmd, false, true)));
				
				// debug info
				const begin:int = textLine.textBlockBeginIndex;
				const end:int = begin + textLine.rawTextLength;
				
				lineElement.node.*[0] = text.substring(begin, end);
				lineElement.size(width, element.hasStyle('lineHeight') ? lineHeight : textHeight);
				
				// Set the line's inline bounds
				lineElement.move(
					textAlign == TextAlign.RIGHT ?
						lineElement.x + width - textLine.width :
						textAlign == TextAlign.CENTER ? 
							(width - textLine.width) * 0.5 :
							lineElement.x,
					lineElement.y,
					Element.INLINE
				);
				lineElement.size(textLine.width, lineElement.height, Element.INLINE);
				
				if(textLine.previousLine) {
					staticLine = textLine.previousLine;
					staticLine.validity = TextLineValidity.STATIC;
				} else {
					staticLine = null;
				}
				
				previousLine = textLine;
				
				lines.push(lineElement);
				
				// Finalize layout and dispatch creation and render messages.
				if(create != null) create(lineElement);
				if(layout != null) layout(lineElement, true);
				
				return [lineElement, true];
			};
			
			function finalizeRun(unusedLineElement:Element):Array {
				
				// Clean up the unused line element.
				// unusedLineElement.dispose();
				
				// Set the run's inline bounds
				const firstLine:Element = (first(lines) as Element) || element;
				const lastLine:Element = (last(lines) as Element) || element;
				
				const firstBounds:Edge = firstLine.bounds(Element.INLINE);
				const lastBounds:Edge = lastLine.bounds(Element.INLINE);
				
				// Set the containing element's inline bounds so they'll
				// be picked up by the element's container for inline layout.
				element.move(element.x, element.y, Element.INLINE);
				element.size(
					lastBounds.right - firstBounds.left,
					lastBounds.bottom - firstBounds.top,
					Element.INLINE
				);
				
				const width:Number = Number(max(lines, 'width'));
				const height:Number = sum(pluck(lines, 'height')) + (Math.max(lines.length - 1, 0) * leading);
				
				element.size(width, height);
				element.setStyle('lines', lines);
				
				if(layout != null) layout(element, true, true);
				
				renderedContent = text;
				renderedWidth = element.width;
				renderedTextIndent = element.textIndent;
				
				return [element, true];
			};
		}
	}
}

import flash.geom.Matrix;
import flash.text.engine.TextLine;

internal var staticLine:TextLine;
internal const matrix:Matrix = new Matrix();

