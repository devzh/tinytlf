
import asx.array.forEach;
import asx.fn.K;

import flash.geom.Point;

import org.tinytlf.Element;
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

private var _css:String = '';
private var cssChanged:Boolean = true;
public function get css():String {
	return _css;
}

public function set css(value:String):void {
	if(_css == value) return;
	
	_css = value;
	cssChanged = true;
}

private var _html:XML = <_/>;
private var htmlChanged:Boolean = false;
public function get html():XML {
	return _html;
}

public function set html(value:*):void {
	if(value === _html) return;
	
	htmlChanged = true;
	// _html = new XML(toXML(value)); // defensive copy
	// pleeease give me valid XML :/
	_html = new XML(value); // defensive copy
	
	if(hasOwnProperty('invalidateDisplayList')) this['invalidateDisplayList']();
	if(hasOwnProperty('invalidate')) this['invalidate']('html');
}

private const renderers:Object = {};

public function mapUI(renderer:Function, ...names):void {
	forEach(names, function(name:String):void { renderers[name] = renderer; });
}

public function getUI(name:String):Function {
	return renderers.hasOwnProperty(name) ?
		renderers[name] :
		renderers['no-mapping'];
}

protected function createUI(element:Element):IObservable {
	const name:String = element.name;
	const render:Function = getUI(name);
	return render(element);
}

protected var documentElement:Element = null;
protected var formatD:Function = K(Observable.value([null, true]));
protected var renderD:Function = K(Observable.value(null));

public function engage(html:XML):void {
	
	documentElement = xmlToElement(html);
	
	// Map HTML formatters for the new document Element.
	mapHTMLFormatters(documentElement);
	
	formatD = getBlockFormatter(documentElement, documentElement);
	renderD = renderDocument(documentElement, createUI);
	
	renderSubscription.cancel();
	renderSubscription = new CompositeCancelable();
	renderObservable = IObservable(renderD(documentElement)).publish();
	renderSubscription.add(renderObservable.connect()); // hot hot hot
}

protected var formatSubscription:CompositeCancelable = new CompositeCancelable();
protected var formatObservable:IConnectableObservable = null;

protected var renderSubscription:CompositeCancelable = new CompositeCancelable();
protected var renderObservable:IConnectableObservable = null;

public function format(start:*, width:Number, height:Number):void {
	
	documentElement.size(
		width,
		Math.max(documentElement.height, height)
	);
	
	const predicateFactory:Function = start is Point ?
		takeWhileFromPoint(documentElement)(start, width, height) :
		takeWhileFromId(start, width, height);
	
	const enumerate:Function = enumerateBlock(documentElement);
	
	formatSubscription.cancel();
	formatSubscription = new CompositeCancelable();
	formatObservable = IObservable(formatD(
		documentElement,
		predicateFactory,
		enumerate, 
		null, null, null)).publish();
	
	formatSubscription.add(formatObservable.connect()); // hot hot hot
}

public function disengage():void {
	formatSubscription.cancel();
	renderSubscription.cancel();
}
