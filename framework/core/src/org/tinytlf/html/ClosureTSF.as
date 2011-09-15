package org.tinytlf.html
{
	import org.tinytlf.layout.sector.*;
	
	public class ClosureTSF implements ITextSectorFactory
	{
		public function ClosureTSF(create:Function = null, parse:Function = null, render:Function = null)
		{
			createFunc = create || function():Array {return [];};
			parseFunc = parse;
			renderFunc = render;
		}
		
		private var createFunc:Function;
		private var parseFunc:Function;
		private var renderFunc:Function;
		
		public function create(dom:IDOMNode):Array
		{
			const val:* = createFunc.length == 2 ?
				createFunc(dom, new ClosureRectangle(parseFunc, renderFunc)) :
				createFunc.length == 1 ? createFunc(dom) : createFunc();
			
			return val ? val is Array ? val : [val] : [];
		}
	}
}
import flash.display.DisplayObject;

import org.tinytlf.layout.sector.*;

internal class ClosureRectangle extends TextRectangle
{
	public function ClosureRectangle(parseF:Function = null, renderF:Function = null)
	{
		parseFunc = parseF || function(rect:TextRectangle):Array {return [];};
		renderFunc = renderF || function(rect:TextRectangle):Array {return [rect];};
	}
	
	private var parseFunc:Function;
	private var renderFunc:Function;
	
	override protected function internalParse():Array
	{
		const val:* = parseFunc.length == 1 ? parseFunc(this) : parseFunc();
		return val ? val is Array ? val : [val] : [];
	}
	
	override public function render():Array
	{
		invalid = false;
		const val:* = renderFunc.length == 1 ? renderFunc(this) : renderFunc();
		return val ? val is Array ? val : val is DisplayObject ? [val] : children : children;
	}
}
