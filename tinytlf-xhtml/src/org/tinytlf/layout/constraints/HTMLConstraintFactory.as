package org.tinytlf.layout.constraints
{
	import flash.text.engine.ContentElement;
	import flash.text.engine.TextLine;
	
	import org.tinytlf.layout.constraints.horizontal.HConstraintFactory;
	import org.tinytlf.util.fte.TextLineUtil;
	
	public class HTMLConstraintFactory extends HConstraintFactory
	{
		override public function getConstraint(line:TextLine, atomIndex:int):ITextConstraint
		{
			var el:ContentElement = TextLineUtil.getElementAtAtomIndex(line, atomIndex);
			
			switch(el.userData)
			{
				case null:
				case undefined:
				case 'lineBreak':
					return null;
				case 'listItemOutside':
					return new OutsideLIConstraint(el);
				case 'listItemInside':
					return new InsideLIConstraint(el);
				default:
					return super.getConstraint(line, atomIndex);
			}
		}
	}
}