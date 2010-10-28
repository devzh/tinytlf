package org.tinytlf.layout.constraints.vertical
{
	import flash.text.engine.TextLine;
	
	import org.tinytlf.layout.constraints.*;
	import org.tinytlf.util.fte.TextLineUtil;
	
	public class VConstraintFactory implements IConstraintFactory
	{
		public function getConstraint(line:TextLine, atomIndex:int):ITextConstraint
		{
			return new VConstraint(TextLineUtil.getElementAtAtomIndex(line, atomIndex));
		}
	}
}