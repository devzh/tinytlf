package org.tinytlf.operations
{
	import org.tinytlf.model.ITLFNode;

	public interface ITextOperation
	{
		function initialize(model:ITLFNode):ITextOperation;
		function execute():void;
		function backout():void;
		function merge(op:ITextOperation):void;
	}
}