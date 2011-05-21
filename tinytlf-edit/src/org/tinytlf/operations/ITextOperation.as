package org.tinytlf.operations
{
	import org.tinytlf.conversion.IHTMLNode;

	public interface ITextOperation
	{
		function initialize(model:IHTMLNode):ITextOperation;
		function execute():void;
		function backout():void;
		function merge(op:ITextOperation):void;
	}
}