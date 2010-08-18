package org.tinytlf.util
{
	import flash.system.Capabilities;
	import flash.text.engine.ContentElement;
	import flash.text.engine.GroupElement;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextLine;
	
	import org.tinytlf.ITextEngine;

	public class TinytlfUtil
	{
		private static var mac:Boolean = (/mac/i).test(Capabilities.os);
		/**
		 * Useful checker to determine what system you're on. Native Mac 
		 * applications respond to different keys than their Windows or Linux
		 * counterparts, and every interaction in tinytlf should be the same as
		 * the native system functions.
		 */
		public static function isMac():Boolean
		{
			return mac;
		}
		
		public static function globalIndexToBlockIndex(engine:ITextEngine, index:int, block:TextBlock):int
		{
			var blockPosition:int = engine.getBlockPosition(block);
			var blockSize:int = engine.getBlockSize(block);
			var blockIndex:int = index - blockPosition;
			
			if(blockIndex < 0)
				blockIndex = 0;
			else if(blockIndex > blockSize)
				blockIndex = blockSize - 1;
			
			return blockIndex;
		}
		
		public static function caretIndexToBlockIndex(engine:ITextEngine, block:TextBlock):int
		{
			return globalIndexToBlockIndex(engine, engine.caretIndex, block);
		}
		
		public static function blockIndexToGlobalIndex(engine:ITextEngine, block:TextBlock, index:int):int
		{
			var blockPosition:int = engine.getBlockPosition(block);
			
			return blockPosition + index;
		}
		
		public static function globalIndexToTextLineAtomIndex(engine:ITextEngine, index:int, line:TextLine):int
		{
			var block:TextBlock = line.textBlock;
			var blockPosition:int = engine.getBlockPosition(block);
			
			var atomIndex:int = index - blockPosition - line.textBlockBeginIndex;
			
			if(atomIndex < 0)
				atomIndex = 0;
			else if(atomIndex > line.atomCount)
				atomIndex = line.atomCount - 1;
			
			return atomIndex;
		}
		
		public static function caretIndexToTextLineAtomIndex(engine:ITextEngine, line:TextLine):int
		{
			return globalIndexToTextLineAtomIndex(engine, engine.caretIndex, line);
		}
		
		public static function atomIndexToGlobalIndex(engine:ITextEngine, line:TextLine, index:int):int
		{
			var blockPosition:int = engine.getBlockPosition(line.textBlock);
			
			return blockPosition + line.textBlockBeginIndex + index;
		}
		
		public static function globalIndexToContentElementIndex(engine:ITextEngine, index:int, 
																element:ContentElement):int
		{
			var block:TextBlock = element.textBlock;
			var blockPosition:int = engine.getBlockPosition(block);
			
			var elementIndex:int = index - blockPosition - element.textBlockBeginIndex;
			
			if(elementIndex < 0)
				elementIndex = 0;
			else if(elementIndex >= element.rawText.length)
				elementIndex = element.rawText.length - 1;
			
			return elementIndex;
		}
		
		public static function caretIndexToContentElementIndex(engine:ITextEngine, element:ContentElement):int
		{
			return globalIndexToContentElementIndex(engine, engine.caretIndex, element);
		}
		
		public static function elementIndexToGlobalIndex(engine:ITextEngine, element:ContentElement, index:int):int
		{
			var blockPosition:int = engine.getBlockPosition(element.textBlock);
			
			return blockPosition + element.textBlockBeginIndex + index;
		}
		
		public static function globalIndexToTextBlock(engine:ITextEngine, index:int):TextBlock
		{
			var blocks:Vector.<TextBlock> = engine.layout.textBlockFactory.blocks;
			var bIndex:int = 0;
			var block:TextBlock;
			var blockPosition:int;
			var blockSize:int;
			
			while(bIndex < blocks.length)
			{
				block = blocks[bIndex];
				blockPosition = engine.getBlockPosition(block);
				blockSize = engine.getBlockSize(block);
				
				if((blockPosition + blockSize) > index)
					break;
				
				++bIndex;
			}
			
			return block;
		}
		
		public static function caretIndexToTextBlock(engine:ITextEngine):TextBlock
		{
			return globalIndexToTextBlock(engine, engine.caretIndex);
		}
		
		public static function globalIndexToTextLine(engine:ITextEngine, index:int):TextLine
		{
			var block:TextBlock = globalIndexToTextBlock(engine, index);
			var charIndex:int = globalIndexToBlockIndex(engine, index, block);
			
			return block.getTextLineAtCharIndex(charIndex);
		}
		
		public static function caretIndexToTextLine(engine:ITextEngine):TextLine
		{
			return globalIndexToTextLine(engine, engine.caretIndex);
		}
		
		public static function globalIndexToContentElement(engine:ITextEngine, index:int):ContentElement
		{
			var block:TextBlock = globalIndexToTextBlock(engine, index);
			var element:ContentElement = block.content;
			var charIndex:int = globalIndexToContentElementIndex(engine, index, element);
			
			if(element is GroupElement)
				return GroupElement(element).getElementAtCharIndex(charIndex);
			
			return element;
		}
		
		public static function caretIndexToContentElement(engine:ITextEngine):ContentElement
		{
			return globalIndexToContentElement(engine, engine.caretIndex);
		}
		
		/**
		 *  Returns true if all of the flags specified by <code>flagMask</code> are set.
		 */
		public static function isBitSet(flags:uint, flagMask:uint):Boolean
		{
			return flagMask == (flags & flagMask);
		}
		
		/**
		 *  Sets the flags specified by <code>flagMask</code> according to <code>value</code>.
		 *  Returns the new bitflag.
		 *  <code>flagMask</code> can be a combination of multiple flags.
		 */
		public static function updateBits(flags:uint, flagMask:uint, update:Boolean = true):uint
		{
			if(update)
			{
				if((flags & flagMask) == flagMask)
					return flags; // Nothing to change
				// Don't use ^ since flagMask could be a combination of multiple flags
				flags |= flagMask;
			}
			else
			{
				if((flags & flagMask) == 0)
					return flags; // Nothing to change
				// Don't use ^ since flagMask could be a combination of multiple flags
				flags &= ~flagMask;
			}
			return flags;
		}
	}
}