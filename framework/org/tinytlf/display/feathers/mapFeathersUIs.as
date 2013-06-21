package org.tinytlf.display.feathers
{
	import asx.fn.K;
	
	import org.tinytlf.Element;
	import org.tinytlf.display.feathers.atoms.box;
	import org.tinytlf.display.feathers.atoms.img;
	import org.tinytlf.display.feathers.atoms.textline;
	
	import raix.reactive.IObservable;
	import raix.reactive.Observable;
	
	import starling.display.Sprite;

	/**
	 * @author ptaylor
	 */
	internal function mapFeathersUIs(window:Sprite, mapUI:Function):void {
		
		const drawBox:Function = box(window);
		const drawImg:Function = img(window);
		const drawLine:Function = textline(window);
		
		mapUI(K(Observable.value(window)), 'no-mapping');
		
		mapUI(
			drawBox,
			'html', 'body', 'article', 'div', 'footer',
			'header', 'section', 'table', 'tbody', 'tr', 'td',
			'p', 'span', 'object'
		);
		
		mapUI(drawImg, 'img');
		mapUI(drawLine, 'line');
	}
}

//			addBlockParser(containerFactory, 'html', 'body', 'article', 'div',
//				'footer', 'header', 'section', 'table', 'tbody').
//					
//				addBlockParser(tableRowFactory, 'tr').
//				addBlockParser(tableCellFactory, 'td').
//				
//				addBlockParser(styleFactory, 'style').
//				
//				addBlockParser(paragraphFactory, 'p', 'span', 'text').
//				
//				addInlineParser(spanFactory, 'span').
//				addInlineParser(textFactory, 'text').
//				
//				// TODO: write head and style parsers
//				addBlockParser(K(null), 'head', 'colgroup', 'img', 'object').
//				// addBlockParser(brBlockFactory, 'head', 'colgroup', 'object').
//				
//				addBlockParser(brBlockFactory, 'br').
//				addInlineParser(br_inline, 'br');
