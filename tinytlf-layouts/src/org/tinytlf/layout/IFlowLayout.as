package org.tinytlf.layout
{
	import org.tinytlf.layout.direction.IFlowDirectionDelegate;

	public interface IFlowLayout extends ITextContainer
	{
		function get direction():IFlowDirectionDelegate;
		function set direction(delegate:IFlowDirectionDelegate):void;
		
		function get elements():Vector.<IFlowLayoutElement>;
	}
}