package org.tinytlf.util
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.text.engine.*;
	import flash.utils.*;
	
	import org.tinytlf.ITextEngine;
	import org.tinytlf.analytics.ITextEngineAnalytics;
	import org.tinytlf.layout.properties.LayoutProperties;
	import org.tinytlf.util.fte.TextLineUtil;
	
	public final class TinytlfUtil
	{
		public static function atomIndexToGlobalIndex(engine:ITextEngine, line:TextLine, atomIndex:int):int
		{
			var a:ITextEngineAnalytics = engine.analytics;
			var blockStart:int = a.blockContentStart(line.textBlock);
			return blockStart + line.textBlockBeginIndex + atomIndex;
		}
		
		public static function globalIndexToAtomIndex(engine:ITextEngine, line:TextLine, globalIndex:int):int
		{
			var a:ITextEngineAnalytics = engine.analytics;
			var blockStart:int = a.blockContentStart(line.textBlock);
			return globalIndex - blockStart - line.textBlockBeginIndex;
		}
		
		public static function globalIndexToTextLine(engine:ITextEngine, globalIndex:int):TextLine
		{
			var a:ITextEngineAnalytics = engine.analytics;
			var block:TextBlock = a.blockAtContent(globalIndex);
			
			if(globalIndex >= a.contentLength)
			{
				block = a.getBlockAt(a.numBlocks - 1);
				--globalIndex;
			}
			
			return block.getTextLineAtCharIndex(globalIndex - a.blockContentStart(block));
		}
		
		public static function globalIndexToAtomBounds(engine:ITextEngine, globalIndex:int):Rectangle
		{
			var a:ITextEngineAnalytics = engine.analytics;
			var b:TextBlock = a.blockAtContent(globalIndex);
			
			if(!b)
				return null;
			
			var blockIndex:int = globalIndex - a.blockContentStart(b);
			var line:TextLine = b.getTextLineAtCharIndex(blockIndex);
			var atomBounds:Rectangle = line.getAtomBounds(blockIndex - line.textBlockBeginIndex);
			atomBounds.offset(line.x, line.y);
			return atomBounds;
		}
		
		public static function pointToGlobalIndex(engine:ITextEngine, point:Point):int
		{
			var a:ITextEngineAnalytics = engine.analytics;
			var blocks:Dictionary = a.cachedBlocks;
			var b:TextBlock;
			var l:TextLine;
			
			for(var tmp:* in blocks)
			{
				b = TextBlock(tmp);
				l = b.firstLine;
				while(l)
				{
					if(l.hitTestPoint(point.x, point.y))
						break;
					
					l = l.nextLine;
				}
				
				if(l)
					break;
			}
			
			if(!l)
				return -1;
			
			var atomIndex:int = TextLineUtil.getAtomIndexAtPoint(l, point);
			
			return a.blockContentStart(b) + l.textBlockBeginIndex + atomIndex;
		}
		
		public static function yToTextLine(engine:ITextEngine, y:Number):TextLine
		{
			var a:ITextEngineAnalytics = engine.analytics;
			var b:TextBlock = a.blockAtPixel(engine.scrollPosition + y);
			
			if(!b)
			{
				if(y < 0)
					return a.getBlockAt(0).firstLine;
				
				return null;
			}
			
			var l:TextLine = b.firstLine;
			var lp:LayoutProperties = getLP(b);
			var h:Number = a.blockPixelStart(b) + lp.paddingTop;
			
			while(l)
			{
				h += l.ascent;
				
				if(h >= y)
					break;
				
				h += l.descent + lp.leading;
				l = l.nextLine;
			}
			
			if(!l && h <= lp.y + lp.height + lp.paddingBottom)
				l = b.lastLine;
			
			return l;
		}
		
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
		
		public static function validPoint(p:Point):Boolean
		{
			return p.x == p.x && p.y == p.y;
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
					return block.userData = new LayoutProperties();
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
			
			return (
				recursiveCompare(objectA, objectB, exceptions) &&
				recursiveCompare(objectB, objectA, exceptions)
				);
		}
		
		private static const compareTypes:Dictionary = new Dictionary();
		
		private static function recursiveCompare(source:Object, 
												 dest:Object, 
												 exceptions:Object = null):Boolean
		{
			exceptions ||= {};
			
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
			if(!(source.constructor in compareTypes))
			{
				var xml:XML = describeType(source);
				compareTypes[source.constructor] = xml..accessor.(@access == 'readwrite');
			}
			
			accessors = compareTypes[source.constructor];
			
			var n:String;
			for each(var x:XML in accessors)
			{
				n = x.@name;
				
				if(n in exceptions)
					continue;
				
				switch(typeof source[n])
				{
					case 'object':
					case 'xml':
						if(!recursiveCompare(source[n], dest[n], exceptions))
							return false;
						break;
					case 'boolean':
					case 'number':
					case 'string':
					case 'function':
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