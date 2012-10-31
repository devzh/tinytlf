package org.tinytlf.layout.rect
{
	import org.swiftsuspenders.*;
	import org.tinytlf.html.*;
	
	/**
	 * <p>
	 * ClosureTRF is a TextRectangle factory which creates an Array of
	 * TextRectangles with a closure.
	 * </p>
	 * 
	 * <p>
	 * If the creation closure accepts two arguments, the first must be an
	 * IDOMNode and the second a TextRectangle. In this case, ClosureTRF ensures
	 * the supplied <code>parse</code> and <code>render</code> functions are 
	 * called when the TextRectangle's <code>parse()</code> and
	 * <code>render()</code> functions are called.
	 * </p>
	 * 
	 * <p>
	 * The parse function can accept nothing, or a TextRectangle. It should
	 * return an array of TextRectangles to be rendered.
	 * </p>
	 * 
	 * <p>
	 * The render function can accept nothing, or a TextRectangle. It should
	 * return nothing, a DisplayObject, or an Array of DisplayObjects. If it
	 * returns DisplayObjects, they will be added to the display list.
	 * </p>
	 */
	public class ClosureTRF implements ITextRectangleFactory
	{
		public function ClosureTRF(injector:Injector, create:Function = null, parse:Function = null, render:Function = null)
		{
			this.injector = injector;
			createFunc = create || function():Array {return [];};
			parseFunc = parse;
			renderFunc = render;
		}
		
		private var injector:Injector;
		private var createFunc:Function;
		private var parseFunc:Function;
		private var renderFunc:Function;
		
		public function create(dom:IDOMNode):Array
		{
			const val:* = createFunc.length == 2 ?
				createFunc(dom, new ClosureRectangle(injector, parseFunc, renderFunc)) :
				createFunc.length == 1 ?
					createFunc(dom) :
					createFunc();
			
			return val ? val is Array ? val : [val] : [];
		}
	}
}
import flash.display.*;

import org.swiftsuspenders.*;
import org.tinytlf.layout.progression.*;
import org.tinytlf.layout.rect.*;

internal class ClosureRectangle extends TextRectangle
{
	public function ClosureRectangle(injector:Injector, parseF:Function = null, renderF:Function = null)
	{
		this.injector = injector;
		parseFunc = parseF || function(rect:TextRectangle):Array {return [];};
		renderFunc = renderF || function(rect:TextRectangle):Array {return rect.children;};
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
		progression.alignment = getAlignmentForProgression(textAlign, blockProgression);
		invalid = false;
		const val:* = renderFunc.length == 1 ? renderFunc(this) : renderFunc();
		return val ? val is Array ? val : val is DisplayObject ? [val] : children : children;
	}
}
