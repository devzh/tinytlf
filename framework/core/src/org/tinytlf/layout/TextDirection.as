/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout
{
    public class TextDirection
    {
        public static const LTR:String = "ltr";
        public static const RTL:String = "rtl";
		
		internal static function isValid(value:String):Boolean
		{
			return value == LTR || value == RTL;
		}
    }
}

