package org.tinytlf.layout.orientation
{
	import flash.text.engine.*;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.layout.IConstraintTextContainer;
	import org.tinytlf.layout.constraints.ITextConstraint;
	import org.tinytlf.layout.properties.*;
	import org.tinytlf.util.fte.TextLineUtil;
	
	public class TextFlowOrientationBase implements IMajorOrientation, IMinorOrientation
	{
		public function TextFlowOrientationBase(target:IConstraintTextContainer)
		{
			this.target = target;
		}
		
		private var layout:IConstraintTextContainer;
		public function set target(flowLayout:IConstraintTextContainer):void
		{
			if(flowLayout === layout)
				return;
			
			layout = flowLayout;
		}
		
		public function get target():IConstraintTextContainer
		{
			return layout;
		}
		
		public function preLayout():void
		{
		}
		
		public function postLayout():void
		{
		}
		
		public function prepForTextBlock(block:TextBlock, line:TextLine):void
		{
		}
		
		public function postTextBlock(block:TextBlock):void
		{
		}
		
		public function getLineSize(block:TextBlock, previousLine:TextLine):Number
		{
			return 0;
		}
		
		public function position(latestLine:TextLine):void
		{
		}
		
		/**
		 * Checks to see if we've laid out lines within the boundaries of our
		 * target container. Returns true if we're outside bounds, false if we 
		 * aren't.
		 */
		public function checkTargetBounds(latestLine:TextLine):Boolean
		{
			var constraints:Vector.<ITextConstraint> = target.constraints;
			
			if(!constraints.length)
				return false;
			
			var e:ITextConstraint = constraints[constraints.length - 1];
			
			// Return true if the last IFlowLayoutElement is a 
			// ContainerTerminator, which causes tinytlf to stop laying out in 
			// this container and move on to the next one.
			
			return (e.constraintMarker === 'containerTerminator');
		}
		
		/**
		 * Called when an element can potentially be added to the list of
		 * IFlowLayoutElements. Override this to respect more types of layout
		 * elements.
		 */
		public function registerConstraint(line:TextLine, atomIndex:int):Boolean
		{
			var constraint:ITextConstraint = createConstraint(line, atomIndex);
			
			if(!constraint)
				return false;
			
			handleConstraint(line, constraint);
			
			return finalizeConstraint(line, constraint);
		}
		
		public function get value():Number
		{
			return 0;
		}
		
		protected function getTotalSize(from:Object = null):Number
		{
			return 0;
		}
		
		protected function createConstraint(line:TextLine, atomIndex:int):ITextConstraint
		{
			var cElement:ContentElement = TextLineUtil.getElementAtAtomIndex(line, atomIndex);
			var constraint:ITextConstraint = target.getConstraint(cElement);
			
			if(!constraint)
			{
				constraint = target.constraintFactory.getConstraint(line, atomIndex);
				if(constraint)
				{
					target.addConstraint(constraint);
				}
			}
			
			return constraint;
		}
		
		protected function handleConstraint(line:TextLine, constraint:ITextConstraint):void
		{
			if(constraint.constraintMarker === 'listItemTerminator')
			{
				handleListItemTermination();
			}
		}
		
		protected function finalizeConstraint(line:TextLine, constraint:ITextConstraint):Boolean
		{
			return constraint.constraintMarker === 'containerTerminator';
		}
		
		/**
		 * When we get to the end of list item, traverse backwards in the
		 * LayoutElement list to the first LIST_ITEM element and remove it.
		 * This ensures we stop flowing around the bullet graphic.
		 */
		protected function handleListItemTermination():void
		{
			var constraints:Vector.<ITextConstraint> = layout.constraints;
			var el:ITextConstraint;
			
			for(var i:int = constraints.length - 1; i >= 0; --i)
			{
				el = constraints[i];
				
				if(	el.constraintMarker === 'listItemOutside' || 
					el.constraintMarker === 'listItemInside')
				{
					target.removeConstraint(el);
					break;
				}
			}
		}
		
		protected function get engine():ITextEngine
		{
			return target ? target.engine : null;
		}
	}
}
