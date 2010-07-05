/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.utils
{
    import flash.geom.Point;
    import flash.text.engine.ContentElement;
    import flash.text.engine.GroupElement;
    import flash.text.engine.TextLine;
    
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
        
        public static function getAtomIndexAtPoint(line:TextLine, stageX:Number, stageY:Number):int
        {
            var atomIndex:int = line.getAtomIndexAtPoint(stageX, stageY);
            
            if(atomIndex == -1)
                return -1;
            
            var atomCenter:int = line.getAtomCenter(atomIndex);
            var atomIncrement:int = (line.localToGlobal(new Point(atomCenter)).x <= stageX) ? 1 : 0;
            
            return Math.max(atomIndex + atomIncrement, 0);
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
            var adjustedIndex:int = line.getAtomTextBlockBeginIndex(atomIndex);/*left ?
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

