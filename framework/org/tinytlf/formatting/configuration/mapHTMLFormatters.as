package org.tinytlf.formatting.configuration
{
	import asx.fn.K;
	import asx.fn.aritize;
	import asx.fn.getProperty;
	import asx.fn.memoize;
	import asx.fn.partial;
	
	import org.tinytlf.Element;
	import org.tinytlf.formatting.configuration.block.mapBlockFormatter;
	import org.tinytlf.formatting.configuration.inline.mapInlineFormatter;
	import org.tinytlf.formatting.formatters.block;
	import org.tinytlf.formatting.formatters.img;
	import org.tinytlf.formatting.formatters.line;
	import org.tinytlf.formatting.formatters.linebreak;
	import org.tinytlf.formatting.formatters.nonFormatted;
	import org.tinytlf.formatting.formatters.run;
	import org.tinytlf.formatting.formatters.style;

	/**
	 * @author ptaylor
	 */
	public function mapHTMLFormatters(document:Element):void {
		
		const styleFormatter:Function = aritize(partial(style, document), 0);
		const blockFormatter:Function = aritize(partial(block, document), 0);
		const lineFormatter:Function = aritize(partial(line, document, ttlfStaticTextBlock), 0);
		const blockBreakFormatter:Function = aritize(partial(linebreak, document, false), 0);
		const inlineBreakFormatter:Function = aritize(partial(linebreak, document, true), 0);
		const runFormatter:Function = aritize(partial(run, document, ttlfStaticTextBlock), 0);
		
		const formatStyle:Function = memoize(styleFormatter, getProperty('key'));
		const formatBlock:Function = memoize(blockFormatter, getProperty('key'));
		const formatLine:Function = memoize(lineFormatter, getProperty('key'));
		const formatBlockLineBreak:Function = memoize(blockBreakFormatter, getProperty('key'));
		const formatInlineLineBreak:Function = memoize(inlineBreakFormatter, getProperty('key'));
		const formatRun:Function = memoize(runFormatter, getProperty('key'));
		const formatImg:Function = img;
		
		mapBlockFormatter(document,
			  formatBlock, 'no-mapping'
			)(formatStyle, 'style'
			)(formatLine, 'b', 'em', 'i', 'p', 'span', 'strong', 'text'
			)(formatBlockLineBreak, 'br'
			// )(formatImg, 'img'
			)(K(nonFormatted), 'img', 'colgroup', 'input'
			);
		
		mapInlineFormatter(document,
			  formatBlock, 'no-mapping'
			)(formatStyle, 'style'
			)(formatRun, 'b', 'em', 'i', 'p', 'span', 'strong', 'text'
			)(formatInlineLineBreak, 'br'
			// )(formatImg, 'img'
			)(K(nonFormatted), 'img', 'colgroup', 'input'
			);
	}
}
