package org.tinytlf.layout.constraints.horizontal
{
	import flash.text.engine.TextLine;
	import org.tinytlf.layout.constraints.*;
	import org.tinytlf.util.fte.TextLineUtil;
	
	public class HConstraintFactory implements IConstraintFactory
	{
		public function getConstraint(line:TextLine, atomIndex:int):ITextConstraint
		{
			return new HConstraint(TextLineUtil.getElementAtAtomIndex(line, atomIndex));
		}
	}
}