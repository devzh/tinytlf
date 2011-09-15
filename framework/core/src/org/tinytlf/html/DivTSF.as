package org.tinytlf.html
{
	import org.swiftsuspenders.*;
	import org.tinytlf.layout.sector.*;
	
	public class DivTSF implements ITextSectorFactory
	{
		[Inject]
		public var injector:Injector;
		
		[Inject]
		public var tsfm:ITextSectorFactoryMap;
		
		public function create(dom:IDOMNode):Array
		{
			const pane:DivPane = new DivPane();
			pane.injector = injector;
			pane.tsfm = tsfm;
			pane.domNode = dom;
			return [pane];
		}
	}
}
import org.tinytlf.html.*;
import org.tinytlf.layout.sector.*;

internal class DivPane extends TextRectangle
{
	public var tsfm:ITextSectorFactoryMap;
	
	override protected function internalParse():Array
	{
		injectInto(domNode.children, false);
		return [this].concat(new ClosureTSF(
							 function(dom:IDOMNode):Array {
								 const rects:Array = [];
								 dom.children.forEach(function(child:IDOMNode, ... args):void {
									 rects.push.apply(null, tsfm.instantiate(child.name).create(child));
								 });
								 return rects;
							 }).create(domNode));
	}
	
	override public function set y(value:Number):void
	{
		if(value == y)
			return;
		
		const thisRect:TextRectangle = this;
		parseCache.forEach(function(rect:TextRectangle, ...args):void {
			if(rect == thisRect)
				return;
			rect.y += value - y;
		});
		super.y = value;
		invalid = false;
	}
	
	override public function set x(value:Number):void
	{
		if(value == x)
			return;
		
		const thisRect:TextRectangle = this;
		parseCache.forEach(function(rect:TextRectangle, ...args):void {
			if(rect == thisRect)
				return;
			rect.x += value - x;
		});
		super.x = value;
		invalid = false;
	}
}
