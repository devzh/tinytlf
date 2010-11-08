package org.tinytlf.util
{
	import flash.system.Capabilities;
	import flash.text.engine.*;
	import flash.utils.*;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.layout.properties.LayoutProperties;
	
	public final class TinytlfUtil
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
		
		/**
		 * Retrieves the LayoutProperties object from the argument passed in.
		 * If no LayoutProperties could be determined, a new instance is 
		 * returned.
		 * 
		 */
		public static function getLP(from:Object = null):LayoutProperties
		{
			if(from is LayoutProperties)
				return LayoutProperties(from);
			
			var block:TextBlock;
			if(from is TextLine)
				block = TextLine(from).textBlock;
			else if(from is TextBlock)
				block = TextBlock(from);
			
			if(block)
			{
				if(block.userData is LayoutProperties)
					return LayoutProperties(block.userData);
				else
					block.userData = new LayoutProperties();
			}
			
			return new LayoutProperties(from);
		}
		
		/**
		 * Like compare, except only primitive types matter.  
		 * If objectA has a child object with no values and objectB doesn't have
		 * that object, they still compare as true because no primitive types
		 * had to be evaluated.
		 *
		 * @return True if the two Object's values are the same, False if 
		 * they're different.
		 */
		public static function compareObjectValues(objectA:Object, 
												   objectB:Object, 
												   exceptions:Object = null):Boolean
		{
			if(!!objectA != !!objectB)
				return false;
			
			if(!recursiveCompare(objectA, objectB, exceptions))
				return false;
			if(!recursiveCompare(objectB, objectA, exceptions))
				return false;
			
			return true;
		}
		
		private static const types:Dictionary = new Dictionary();
		
		private static function recursiveCompare(source:Object, 
												 dest:Object, 
												 exceptions:Object = null):Boolean
		{
			if(source is Array)
			{
				if(source.length != dest.length)
					return false;
				
				for(var i:int = 0; i < source.length; i += 1)
				{
					if(source[i] !== dest[i])
					{
						return false;
					}
				}
				
				return true;
			}
			if(source is XML || source is XMLList)
			{
				if(source.length() != dest.length())
					return false;
				
				return source === dest;
			}
			
			var accessors:XMLList;
			if(source.constructor in types)
			{
				accessors = types[source.constructor];
			}
			else
			{
				var xml:XML = describeType(source);
				types[source.constructor] = accessors = xml..accessor.(@access == 'readwrite');
			}
			
			var n:String;
			for each(var x:XML in accessors)
			{
				n = x.@name;
				
				if(exceptions && n in exceptions)
					continue;
				
				switch(typeof source[n])
				{
					case 'object':
					case 'xml':
						if(!recursiveCompare(source[n], dest[n]))
							return false;
						break;
					case 'boolean':
					case 'number':
					case 'string':
						if(source[n] !== dest[n])
							return false;
						break;
				}
			}
			
			return true;
		}
		
		/**
		 * Converts a string from underscore or dash separators to no separators.
		 */
		public static function stripSeparators(str:String):String
		{
			var s:String = str.replace(/(-|_)(\w)/g, function(...args):String{
				return String(args[2]).toUpperCase();
			});
			
			return s.replace(/(-|_)/g, '');
		}
		
		private static var typeCache:Dictionary = new Dictionary(false);
		
		public static function describeType(value:Object, refreshCache:Boolean = false):XML
		{
			if(!(value is Class))
			{
				if(value is Proxy)
					value = getDefinitionByName(getQualifiedClassName(value)) as Class;
				else if(value is Number)
					value = Number;
				else
					value = value.constructor as Class;
			}
			
			if(refreshCache || typeCache[value] == null)
			{
				typeCache[value] = flash.utils.describeType(value);
			}
			
			return typeCache[value];
		}
	}
}