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
			
			if(el.userData == null)
				return null;
			
			if(el.userData === TextLineUtil.getSingletonMarker('lineBreak'))
				return null;
			
			if(el.userData === TextLineUtil.getSingletonMarker('listItemOutside'))
				return new OutsideLIConstraint(el);
			if(el.userData === TextLineUtil.getSingletonMarker('listItemInside'))
				return new InsideLIConstraint(el);
			
			return super.getConstraint(line, atomIndex);
		}
	}
}