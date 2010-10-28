package org.tinytlf.layout.constraints
{
	import flash.text.engine.ContentElement;
	import flash.text.engine.TextLine;

	public interface IConstraintFactory
	{
		function getConstraint(line:TextLine, atomIndex:int):ITextConstraint;
	}
}