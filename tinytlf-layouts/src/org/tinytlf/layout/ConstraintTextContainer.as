package org.tinytlf.layout
{
	import flash.display.*;
	import flash.text.engine.*;
	
	import org.tinytlf.layout.constraints.*;
	import org.tinytlf.layout.orientation.*;
	import org.tinytlf.layout.orientation.horizontal.*;
	import org.tinytlf.layout.properties.LayoutProperties;
	import org.tinytlf.util.TinytlfUtil;
	import org.tinytlf.util.fte.*;
	
	public class ConstraintTextContainer extends TextContainerBase implements IConstraintTextContainer
	{
		public function ConstraintTextContainer(container:Sprite, 
												explicitWidth:Number = NaN, 
												explicitHeight:Number = NaN)
		{
			super(container, explicitWidth, explicitHeight);
			
			constraintFactory = new ConstraintFactory();
			
			majorDirection = new LTRMajor(this);
			minorDirection = new HMinor(this);
		}
		
		private var major:IMajorOrientation;
		
		public function get majorDirection():IMajorOrientation
		{
			return major;
		}
		
		public function set majorDirection(delegate:IMajorOrientation):void
		{
			if(delegate == major)
				return;
			
			major = delegate;
			major.target = this;
			
			if(engine)
				engine.invalidate();
		}
		
		private var minor:IMinorOrientation;
		
		public function get minorDirection():IMinorOrientation
		{
			return minor;
		}
		
		public function set minorDirection(delegate:IMinorOrientation):void
		{
			if(delegate == minor)
				return;
			
			minor = delegate;
			minor.target = this;
			
			if(engine)
				engine.invalidate();
		}
		
		private var _constraintFactory:IConstraintFactory;
		
		public function set constraintFactory(factory:IConstraintFactory):void
		{
			if(factory === _constraintFactory)
				return;
			
			_constraintFactory = factory;
		}
		
		public function get constraintFactory():IConstraintFactory
		{
			return _constraintFactory;
		}
		
		protected var _constraints:Vector.<ITextConstraint> = new <ITextConstraint>[];
		
		public function get constraints():Vector.<ITextConstraint>
		{
			return _constraints.concat();
		}
		
		public function addConstraint(constraint:ITextConstraint):void
		{
			if(!constraint)
				return;
			
			if(getConstraint(constraint.content))
				return;
			
			_constraints.push(constraint);
		}
		
		public function getConstraint(element:*):ITextConstraint
		{
			var n:int = _constraints.length;
			var constraint:ITextConstraint;
			
			for(var i:int = 0; i < n; i += 1)
			{
				constraint = _constraints[i];
				if(constraint.content === element)
					return constraint;
			}
			
			return null;
		}
		
		public function removeConstraint(constraint:ITextConstraint):void
		{
			var i:int = _constraints.indexOf(constraint);
			if(i != -1)
				_constraints.splice(i, 1);
		}
		
		override public function preLayout():void
		{
			super.preLayout();
			
			major.preLayout();
			minor.preLayout();
		}
		
		override public function postLayout():void
		{
			super.postLayout();
			
			major.postLayout();
			minor.postLayout();
		}
		
		override public function layout(block:TextBlock, previousLine:TextLine):TextLine
		{
			if(TextBlockUtil.isInvalid(block))
				return renderBlockLines(block, previousLine);
			
			return checkBlockLines(block);
		}
		
		private function checkBlockLines(block:TextBlock):TextLine
		{
			var line:TextLine = block.firstLine;
			var lp:LayoutProperties = TinytlfUtil.getLP(block);
			
			minor.prepForTextBlock(block, null);
			
			while(line)
			{
				if(hasLine(line))
				{
					major.position(line);
					minor.position(line);
					
					if(minor.checkTargetBounds(line))
					{
						break;
					}
					
					line = line.nextLine;
				}
				else
				{
					break;
				}
			}
			
			minor.postTextBlock(block);
			
			return line;
		}
		
		private function renderBlockLines(block:TextBlock, previousLine:TextLine):TextLine
		{
			minor.prepForTextBlock(block, previousLine);
			major.prepForTextBlock(block, previousLine);
			
			var line:TextLine = checkLineBreakJustification(block, createTextLine(block, previousLine));
			
			while(line)
			{
				addLineToTarget(line);
				
				registerLine(line);
				
				major.position(line);
				minor.position(line);
				
				findConstraints(line);
				
				if(minor.checkTargetBounds(line))
					return line;
				
				line = checkLineBreakJustification(block, createTextLine(block, line));
			}
			
			major.postTextBlock(block);
			minor.postTextBlock(block);
			
			return null;
		}
		
		override protected function createTextLine(block:TextBlock, previousLine:TextLine):TextLine
		{
			var size:Number = major.getLineSize(block, previousLine);
			
			var orphan:TextLine = getRecycledLine(previousLine);
			if(orphan)
				return block.recreateTextLine(orphan, previousLine, size, 0.0, true);
			
			return block.createTextLine(previousLine, size, 0.0, true);
		}
		
		override protected function invalidateVisibleLines():void
		{
			super.invalidateVisibleLines();
			
			_constraints.length = 0;
		}
		
		protected function findConstraints(line:TextLine):void
		{
			if(!line.hasGraphicElement)
				return;
			
			var n:int = line.atomCount;
			for(var i:int = 0; i < n; i += 1)
				if(line.getAtomGraphic(i))
					if(major.registerConstraint(line, i))
						return;
		}
		
		/**
		 * @private
		 * Checks to see if the input TextLine needs to be recreated due to the
		 * combination of justification and a <br/> style line break.
		 *
		 * This achieves the "HTML-style" line break for justified text.
		 */
		private function checkLineBreakJustification(block:TextBlock, line:TextLine):TextLine
		{
			if(!block || !line)
				return line;
			
			// If we're not justified ALL_BUT_LAST, exit early. If they're
			// justified ALL_INCLUDING_LAST, they want the last line justified
			// anyway, so we don't mind that a <br/> tag caused the 
			// justification spacing to look funny.
			var justifier:TextJustifier = block.textJustifier;
			if(!justifier)
				return line;
			
			if(justifier.lineJustification !== LineJustification.ALL_BUT_LAST)
				return line;
			
			if(!TextLineUtil.hasLineBreak(line))
				return line;
			
			// We've broken a justified line, it does have a line break graphic 
			// at the end, and it's going to look funny. So re-break the line 
			// using the unjustifiedWidth instead of the total width.
			return block.recreateTextLine(
				line, 
				line.previousLine, 
				Math.min(line.unjustifiedTextWidth, line.textWidth), 
				0.0, 
				true)
		}
	}
}

import flash.text.engine.TextLine;

import org.tinytlf.layout.constraints.*;
import org.tinytlf.util.fte.TextLineUtil;

internal class ConstraintFactory implements IConstraintFactory
{
	public function getConstraint(line:TextLine, atomIndex:int):ITextConstraint
	{
		return new TextConstraintBase(TextLineUtil.getElementAtAtomIndex(line, atomIndex));
	}
}