/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.util
{
    import flash.geom.Point;
    import flash.text.engine.ContentElement;
    import flash.text.engine.GroupElement;
    import flash.text.engine.TextLine;
    
    import org.tinytlf.util.Type;
    
    public class FTEUtil
    {
        public static function getContentElementAt(element:ContentElement, index:int):ContentElement
        {
            var idx:int = index;
            while(element is GroupElement)
            {
                idx = index - element.textBlockBeginIndex;
                idx = (idx <= 0) ? 1 : (idx < element.rawText.length) ? idx : element.rawText.length - 1
                if(idx < Math.max(element.rawText.length, GroupElement(element).elementCount))
                    element = GroupElement(element).getElementAtCharIndex(idx);
                else
                    break;
            }
            
            return element;
        }
		
		public static function getAdjustedLineExtremity(line:TextLine, stageX:Number, stageY:Number):int
		{
			var pt:Point = line.localToGlobal(new Point(0, 1));
			if(stageX < pt.x)
				return 0;
			else if(stageX > pt.x)
				return line.atomCount;
			
			return line.getAtomIndexAtPoint(stageX, pt.y);
		}
        
        public static function getAtomIndexAtPoint(line:TextLine, stageX:Number, stageY:Number):int
        {
            var atomIndex:int = line.getAtomIndexAtPoint(stageX, stageY);
            
            if(atomIndex == -1)
                return -1;
            
            var atomIncrement:int = getAtomSide(line, stageX, stageY) ? 0 : 1;
            
            return Math.max(atomIndex + atomIncrement, 0);
        }
		
		/**
		 * Finds which side of the atom the specified x and y position is on.
		 * @returns True for left, False for right.
		 */
		public static function getAtomSide(line:TextLine, stageX:Number, stageY:Number):Boolean
		{
            var atomIndex:int = line.getAtomIndexAtPoint(stageX, stageY);
            
            if(atomIndex == -1)
                return true;
            
            return line.localToGlobal(new Point(line.getAtomCenter(atomIndex))).x > stageX;
		}
        
        private static const defaultWordBoundaryPattern:RegExp = /\W+|\b[^\W﷯]*/;
        private static const nonWordPattern:RegExp = /\W/;
        
        public static function getAtomWordBoundary(line:TextLine, atomIndex:int, left:Boolean = true, pattern:RegExp = null):int
        {
            if(!pattern)
                pattern = defaultWordBoundaryPattern;
            
            if(atomIndex < 0)
                return atomIndex;
            
            if(atomIndex >= line.atomCount)
                atomIndex = line.atomCount - 1;
            
            var rawText:String = line.textBlock.content.rawText;
            var adjustedIndex:int = line.getAtomTextBlockBeginIndex(atomIndex);
            /*left ?
               line.getAtomTextBlockBeginIndex(atomIndex) :
             line.getAtomTextBlockEndIndex(atomIndex);*/
            
            if(nonWordPattern.test(rawText.charAt(adjustedIndex)))
            {
                return atomIndex;
            }
            else
            {
                var text:String = left ?
                    rawText.slice(0, adjustedIndex).split("").reverse().join("") :
                    rawText.slice(adjustedIndex + 1, rawText.length);
                
                var match:Array = pattern.exec(text);
                if(match)
                {
                    var str:String = String(match[0]);
                    atomIndex += nonWordPattern.test(str) ? 0 : str.length * (left ? -1 : 1);
                }
            }
            
            return Math.max(atomIndex, 0);
        }
        
        /**
        * Compares the properties of two objects, including the properties of sub-properties and so on.
        * @return true if there are differences, false otherwise.
        */
        public static function compare(a:*, b:*):Boolean
        {
            var aClass:Class = Type.getType(a);
            
            if(!(b is aClass))
                throw new Error('Cannot compare objects of different types.');
            
            if(a is Number || a is int || a is uint || a is String || a is Boolean)
                return a !== b;
            
            var properties:XMLList = Type.describeProperties(a);
            
            for each(var prop:* in properties)
            {
                prop = prop.@name.toString();
                if(prop in b)
                    if(compare(a[prop], b[prop]))
                        return true;
            }
            
            return false;
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

