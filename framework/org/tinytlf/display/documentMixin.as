
import asx.array.forEach;
import asx.fn.I;
import asx.fn.K;

import flash.geom.Point;

import org.tinytlf.Element;
import org.tinytlf.atoms.configuration.initializers.getAtomInitializer;
import org.tinytlf.atoms.configuration.renderers.getAtomRenderer;
import org.tinytlf.atoms.renderAtom;
import org.tinytlf.css.applyCSSPredicates;
import org.tinytlf.css.clearCSSPredicates;
import org.tinytlf.css.injectCSSPredicates;
import org.tinytlf.display.renderDocument;
import org.tinytlf.formatting.configuration.block.getBlockFormatter;
import org.tinytlf.formatting.configuration.mapHTMLFormatters;
import org.tinytlf.formatting.traversal.enumerateBlock;
import org.tinytlf.formatting.traversal.takeWhileFromId;
import org.tinytlf.formatting.traversal.takeWhileFromPoint;
import org.tinytlf.xml.toXML;
import org.tinytlf.xml.xmlToElement;

import raix.reactive.Cancelable;
import raix.reactive.CompositeCancelable;
import raix.reactive.ICancelable;
import raix.reactive.IObservable;
import raix.reactive.Observable;
import raix.reactive.subjects.IConnectableObservable;

[Embed(source = "default.css", mimeType = "application/octet-stream")]
private const defaultCSS:Class;

protected var documentRendered:Boolean = false;

private var _css:String = '';
protected var cssChanged:Boolean = true;
public function get css():String {
	return _css;
}

public function set css(value:String):void {
	if(_css == value) return;
	
	_css = value;
	cssChanged = true;
	documentRendered = false;
}

private var _html:XML = <_/>;
protected var htmlChanged:Boolean = false;
public function get html():XML {
	return _html;
}

public function set html(value:*):void {
	if(value === _html) return;
	
	htmlChanged = true;
	documentRendered = false;
	// _html = new XML(toXML(value)); // defensive copy
	// pleeease give me valid XML :/
	
	XML.prettyPrinting = false;
	XML.prettyIndent = 0;
	XML.ignoreWhitespace = false;
	
	_html = new XML(value); // defensive copy
	
	if(hasOwnProperty('invalidateDisplayList')) this['invalidateDisplayList']();
	if(hasOwnProperty('invalidate')) this['invalidate']('html');
}

//private const renderers:Object = {};
//
//public function mapUI(renderer:Function, ...names):void {
//	forEach(names, function(name:String):void { renderers[name] = renderer; });
//}
//
//public function getUI(name:String):Function {
//	return renderers.hasOwnProperty(name) ?
//		renderers[name] :
//		renderers['no-mapping'];
//}
//
//protected function createUI(element:Element):IObservable {
//	const name:String = element.name;
//	const render:Function = getUI(name);
//	return render(element, asynchronous);
//}


private function initializer(element:Element):void {
	getAtomInitializer(documentElement, element)(element);
}

private function renderer(element:Element):void {
	getAtomRenderer(documentElement, element)(element);
}

public var documentElement:Element = null;
public var asynchronous:Boolean = true;

public function disengage():void {
	formatSubscription.cancel();
}

protected var formatSubscription:ICancelable = Cancelable.empty;

public function format(start:*, width:Number, height:Number):IObservable {
	
	documentElement.size(width, height);
	
	const predicateFactory:Function = start is Point ?
		takeWhileFromPoint(documentElement)(start, width, height) :
		takeWhileFromId(start, width, height);
	
	const render:Function = renderAtom(0, 0, initializer, renderer);
	
	const formatD:Function = getBlockFormatter(documentElement, documentElement);
	return formatD(
		documentElement,
		predicateFactory,
		enumerateBlock(documentElement),
		null, I, render).delay(10);
}
