package org.tinytlf.layout
{
	import flash.text.engine.ContentElement;
	import flash.text.engine.TextLine;

	public interface ILayoutElementFactory
	{
		function getLayoutElement(line:TextLine, atomIndex:int):IFlowLayoutElement;
	}
}