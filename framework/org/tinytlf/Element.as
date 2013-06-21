package org.tinytlf
{
	import asx.array.anyOf;
	import asx.array.forEach;
	import asx.fn.areEqual;
	import asx.fn.partial;
	
	import flash.geom.Point;
	import flash.utils.ByteArray;
	import flash.utils.flash_proxy;
	
	import org.tinytlf.enum.TextAlign;
	import org.tinytlf.enum.TextBlockProgression;
	import org.tinytlf.enum.TextDirection;
	import org.tinytlf.xml.readKey;
	import org.tinytlf.xml.wrapTextNodes;
	import org.tinytlf.xml.xmlToElement;
	
	import raix.reactive.Cancelable;
	import raix.reactive.ICancelable;
	import raix.reactive.ISubject;
	import raix.reactive.Subject;
	import raix.reactive.scheduling.Scheduler;
	import raix.reactive.subjects.BehaviorSubject;
	import raix.reactive.subjects.ReplaySubject;
	
	import trxcllnt.Store;
	
	public class Element extends Store
	{
		public static const LOCAL:int = 0;
		public static const INLINE:int = 1;
		public static const GLOBAL:int = 2;
		
		public function Element()
		{
			super();
		}
		
		public static function fromXML(node:XML):Element {
			return xmlToElement(node);
		}
		
		public function hasStyle(style:String):Boolean {
			return flash_proxy::hasProperty(style);
		}
		
		public function getStyle(style:String):* {
			return flash_proxy::getProperty(style);
		}
		
		public function setStyle(style:String, value:*):Element {
			flash_proxy::setProperty(style, value);
			return this;
		}
		
		public function isRoot():Boolean {
			return parent == null;
		}
		
		public function move(x:Number, y:Number, ...types):Element {
			
			if(types.length == 0) types.push(LOCAL);
			
			forEach(types, function(type:int):void {
				bounds(type).setTo(y, x + width, y + height, x);
			});
			
			return this;
		}
		
		public function size(w:Number, h:Number, ...types):Element {
			
			if(types.length == 0) types.push(LOCAL);
			
			forEach(types, function(type:int):void {
				const constraints:Edge = constrain(w, h);
				const edge:Edge = bounds(type);
				edge.setTo(NaN, edge.left + constraints.width, edge.top + constraints.height, NaN);
			});
			
			return this;
		}
		
		public function offset(type:int = 0):Point {
			return bounds(type).topLeft;
		}
		
		private var addSubscription:ICancelable = Cancelable.empty;
		
		public function addTo(container:Element):Element {
			container.elements.onNext(this);
			return this;
		}
		
		private var renderSubscription:ICancelable = Cancelable.empty;
		
		public function render():Element {
			_rendered.onNext(this);
			return this;
		}
		
		private var _cssPredicates:Array = [];
		public function get cssPredicates():Array {
			return _cssPredicates;
		}
		
		public function set cssPredicates(predicates:Array):void {
			if(predicates == _cssPredicates) return;
			_cssPredicates = predicates.concat();
		}
		
		private var _depth:int = 0;
		public function get depth():int {
			return _depth;
		}
		
		public function set depth(value:int):void {
			_depth = value;
		}
		
		private const _elements:ISubject = new ReplaySubject();
		public function get elements():ISubject {
			return _elements;
		}
		
		private const _rendered:ISubject = new BehaviorSubject();
		public function get rendered():ISubject {
			return _rendered;
		}
		
		private var _key:String = '';
		public function get key():String {
			return _key;
		}
		
		public function set key(value:String):void {
			_key = value;
		}
		
		private var _node:XML = <_/>;
		public function get node():XML {
			return _node;
		}
		
		public function set node(value:XML):void {
			
			const inlineElements:Array = ['strong', 'span', 'text', 'line', 'em', 'b', 'i'];
			
			_node = wrapTextNodes.apply(null, [value, false, 'style'].concat(inlineElements));
			_key = readKey(value);
			_index = value.childIndex();
			
			_classes.length = 0;
			_classes.push.apply(_classes, (value.attribute('class').toString() || '').split(' '));
			
			// TODO: do this somewhere else.
			
			if(anyOf(inlineElements, partial(areEqual, name))) {
				setStyle('display', 'inline');
			} else {
				setStyle('display', 'block');
			}
		}
		
		public function get children():XMLList {
			return node.*;
		}
		
		public function get descendents():XMLList {
			return node..*;
		}
		
		public function get id():String {
			return node.@id || '';
		}
		
		private var _index:int = -1;
		public function get index():int {
			return _index;
		}
		
		public function set index(value:int):void {
			_index = value;
		}
		
		public function get name():String {
			return node.localName();
		}
		
		public function get numChildren():int {
			return node.*.length();
		}
		
		public function get numDescendents():int {
			return node..*.length();
		}
		
		public function get parent():XML {
			return node.parent();
		}
		
		public function get text():String {
			return node.nodeKind() == 'element' ?
				node.text().toString() :
				node.toString();
		}
		
		public function get x():Number {
			return bounds().left;
		}
		
		public function get y():Number {
			return bounds().top;
		}
		
		public function get width():Number {
			return bounds().width;
		}
		
		public function set width(value:Number):void {
			setStyle('width', value);
		}
		
		public function get height():Number {
			return bounds().height;
		}
		
		public function set height(value:Number):void {
			setStyle('height', value);
		}
		
		public function get backgroundColor():uint {
			return getStyle('backgroundColor') || NaN;
		}
		
		public function get backgroundAlpha():uint {
			return getStyle('backgroundAlpha') || 1;
		}
		
		public function get backgroundImage():String {
			return getStyle('backgroundImage') || '';
		}
		
		public function get backgroundImageAlpha():uint {
			return getStyle('backgroundImageAlpha') || 1;
		}
		
		public function get blockProgression():String {
			return getStyle('blockProgression') || TextBlockProgression.TTB;
		}
		
		public function get clear():String {
			return getStyle('clear') || 'none';
		}
		
		public function get display():String {
			return getStyle('display') || 'block';
		}
		
		public function get direction():String {
			return getStyle('textDirection') || getStyle('direction') || TextDirection.LTR;
		}
		
		public function get float():String {
			return getStyle('float') || 'none';
		}
		
		public function get fontSize():Number {
			return getStyle('fontSize') || 12;
		}
		
		public function get leading():Number {
			return getStyle('leading') || 0;
		}
		
		public function get lineHeight():Number {
			return getStyle('lineHeight') || fontSize;
		}
		
		public function get locale():String {
			return getStyle('locale') || 'en';
		}
		
		public function get textAlign():String {
			return getStyle('textAlign') || TextAlign.LEFT;
		}
		
		public function get textIndent():Number {
			return getStyle('textIndent') || 0;
		}
		
		public function get top():Number {
			return getStyle('top') || 0;
		}
		
		public function get right():Number {
			return getStyle('right') || 0;
		}
		
		public function get bottom():Number {
			return getStyle('bottom') || 0;
		}
		
		public function get left():Number {
			return getStyle('left') || 0;
		}
		
		public function get borderTop():Number {
			return getStyle('borderTopWidth') || getStyle('borderWidth') || 0;
		}
		
		public function get borderRight():Number {
			return getStyle('borderRightWidth') || getStyle('borderWidth') || 0;
		}
		
		public function get borderBottom():Number {
			return getStyle('borderBottomWidth') || getStyle('borderWidth') || 0;
		}
		
		public function get borderLeft():Number {
			return getStyle('borderLeftWidth') || getStyle('borderWidth') || 0;
		}
		
		public function get borderTopAlpha():Number {
			return getStyle('borderTopAlpha') || getStyle('borderAlpha') || 1;
		}
		
		public function get borderRightAlpha():Number {
			return getStyle('borderRightAlpha') || getStyle('borderAlpha') || 1;
		}
		
		public function get borderBottomAlpha():Number {
			return getStyle('borderBottomAlpha') || getStyle('borderAlpha') || 1;
		}
		
		public function get borderLeftAlpha():Number {
			return getStyle('borderLeftAlpha') || getStyle('borderAlpha') || 1;
		}
		
		public function get borderTopColor():Number {
			return getStyle('borderTopColor') || getStyle('borderColor') || NaN;
		}
		
		public function get borderRightColor():Number {
			return getStyle('borderRightColor') || getStyle('borderColor') || NaN;
		}
		
		public function get borderBottomColor():Number {
			return getStyle('borderBottomColor') || getStyle('borderColor') || NaN;
		}
		
		public function get borderLeftColor():Number {
			return getStyle('borderLeftColor') || getStyle('borderColor') || NaN;
		}
		
		public function get marginTop():Number {
			return getStyle('marginTop') || getStyle('margin') || 0;
		}
		
		public function get marginRight():Number {
			return getStyle('marginRight') || getStyle('margin') || 0;
		}
		
		public function get marginBottom():Number {
			return getStyle('marginBottom') || getStyle('margin') || 0;
		}
		
		public function get marginLeft():Number {
			return getStyle('marginLeft') || getStyle('margin') || 0;
		}
		
		public function get paddingTop():Number {
			return getStyle('paddingTop') || getStyle('padding') || 0;
		}
		
		public function get paddingRight():Number {
			return getStyle('paddingRight') || getStyle('padding') || 0;
		}
		
		public function get paddingBottom():Number {
			return getStyle('paddingBottom') || getStyle('padding') || 0;
		}
		
		public function get paddingLeft():Number {
			return getStyle('paddingLeft') || getStyle('padding') || 0;
		}
		
		public function get absWidth():Number {
			return hasStyle('width') ? getStyle('width') : NaN;
		}
		
		public function get absHeight():Number {
			return hasStyle('height') ? getStyle('height') : NaN;
		}
		
		public function get minWidth():Number {
			return getStyle('minWidth') || 0;
		}
		
		public function get maxWidth():Number {
			return getStyle('maxWidth') || int.MAX_VALUE;
		}
		
		public function get minHeight():Number {
			return getStyle('minHeight') || 0;
		}
		
		public function get maxHeight():Number {
			return getStyle('maxHeight') || int.MAX_VALUE;
		}
		
		public function get position():String {
			return getStyle('position') || 'static';
		}
		
		public function get overflow():String {
			return getStyle('overflow') || 'visible';
		}
		
		public function get vAlign():String {
			return getStyle('verticalAlign') || 'baseline';
		}
		
		public function get bordersCollapsed():Boolean {
			return getStyle('borderCollapse') == 'collapse';
		}
		
		private const _classes:Array = [];
		
		public function classed(className:String):Boolean {
			return anyOf(_classes, partial(areEqual, className));
		}
		
		public function cleared(...values):Boolean {
			return anyOf(values, partial(areEqual, clear));
		}
		
		public function displayed(...values):Boolean {
			return anyOf(values, partial(areEqual, display));
		}
		
		public function floated(...values):Boolean {
			return anyOf(values, partial(areEqual, float));
		}
		
		public function positioned(...values):Boolean {
			return anyOf(values, partial(areEqual, position));
		}
		
		public function overflowed(...values):Boolean {
			return anyOf(values, partial(areEqual, overflow));
		}
		
		private const constrainHelper:Edge = new Edge();
		public function constrain(width:Number, height:Number):Edge {
			return constrainHelper.setTo(
				0, // top
				Math.max(Math.min(absWidth == absWidth   ? absWidth  : width,  maxWidth),  minWidth), // right
				Math.max(Math.min(absHeight == absHeight ? absHeight : height, maxHeight), minHeight), // bottom
				0 // left
			);
		}
		
		public function get hasInlineBounds():Boolean {
			return bounds(INLINE).isEmpty() == false &&
				bounds().compareTo(bounds(INLINE)) == false;
		}
		
		private const boundsEdges:Array = [
			new Edge(), // local
			new Edge(), // inline
			new Edge()  // global
		];
		
		public function bounds(type:int = 0):Edge {
			return boundsEdges[type];
		}
		
		private const insideBoundsHelper:Edge = new Edge();
		public function inside(collapse:Boolean = false):Edge {
			return collapse ?
				insideBoundsHelper.setTo(
					paddingTop, // top
					width - paddingRight, // right
					height - paddingBottom, // bottom
					paddingLeft // left
				) :
				insideBoundsHelper.setTo(
					borderTop + paddingTop, // top
					width - borderRight - paddingRight, // right
					height - borderBottom - paddingBottom, // bottom
					borderLeft + paddingLeft // left
				);
		}
		
		private const outsideBoundsHelper:Edge = new Edge();
		public function get outside():Edge {
			return outsideBoundsHelper.setTo(
				- marginTop, // top
				width + marginRight, // right
				height + marginBottom, // bottom
				- marginLeft // left
			);
		}
		
		private const innerBoundsHelper:Edge = new Edge();
		public function get innerBounds():Edge {
			return innerBoundsHelper.setTo(
				y + borderTop + paddingTop, // top
				x + width - borderRight - paddingRight, // right
				y + height - borderBottom - paddingBottom, // bottom
				x + borderLeft + paddingLeft // left
			);
		}
		
		private const outerBoundsHelper:Edge = new Edge();
		public function get outerBounds():Edge {
			return outerBoundsHelper.setTo(
				y - marginTop, // top
				x + width + marginLeft + marginRight, // right
				y + height + marginTop + marginBottom, // bottom
				x - marginLeft // left
			);
		}
		
		private const borderHelper:Edge = new Edge();
		public function get borders():Edge {
			return borderHelper.setTo(borderTop, borderRight, borderBottom, borderLeft);
		}
		
		private const constraintHelper:Edge = new Edge();
		public function get constraints():Edge {
			return constraintHelper.setTo(top, right, bottom, left);
		}
		
		private const marginHelper:Edge = new Edge();
		public function get margins():Edge {
			return marginHelper.setTo(marginTop, marginRight, marginBottom, marginLeft);
		}
		
		private const paddingHelper:Edge = new Edge();
		public function get padding():Edge {
			return paddingHelper.setTo(paddingTop, paddingRight, paddingBottom, paddingLeft);
		}
		
		private var _disposed:Boolean = false;
		public function get isDisposed():Boolean {
			return _disposed;
		}
		
		public function dispose():Element {
			
			_disposed = true;
			
			_node = null;
			_key = null;
			
			addSubscription.cancel();
			renderSubscription.cancel();
			
			constrainHelper.setTo(0, 0, 0, 0);
			bounds(LOCAL).setTo(0, 0, 0, 0);
			bounds(INLINE).setTo(0, 0, 0, 0);
			bounds(GLOBAL).setTo(0, 0, 0, 0);
			innerBoundsHelper.setTo(0, 0, 0, 0);
			outerBoundsHelper.setTo(0, 0, 0, 0);
			borderHelper.setTo(0, 0, 0, 0);
			constraintHelper.setTo(0, 0, 0, 0);
			marginHelper.setTo(0, 0, 0, 0);
			paddingHelper.setTo(0, 0, 0, 0);
			
			properties = null;
			
			propNames.length = 0;
			propNames = null;
			
			return this;
		}
	}
}

