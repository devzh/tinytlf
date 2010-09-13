package org.tinytlf.layout
{
	import org.tinytlf.layout.direction.IFlowDirectionDelegate;

	public interface IFlowLayout extends ITextContainer
	{
		function set direction(delegate:IFlowDirectionDelegate):void;
		function set elementFactory(factory:ILayoutElementFactory):void;
		
		function get elements():Vector.<IFlowLayoutElement>;
	}
}