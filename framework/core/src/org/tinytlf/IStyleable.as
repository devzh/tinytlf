/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf
{
	/**
	 * An interface for an object that has styles.
	 */
    public interface IStyleable
    {
		/**
		 * Clears a style's definition and value from this implementation.
		 */
        function clearStyle(styleProp:String):Boolean;
		
		/**
		 * Gets the value for a style property. Can return null if this object's
		 * styles aren't set up, or undefined if the styleProp isn't a style on
		 * this instance.
		 */
        function getStyle(styleProp:String):*;
		
		/**
		 * Sets a styleProp to the value defined by newValue.
		 */
        function setStyle(styleProp:String, newValue:*):void;
		
		/**
		 * Applies this IStyleable's styles to the specified Object.
		 */
		function applyTo(target:Object, dynamic:Boolean = false):IStyleable;
		
		/**
		 * Unapplies this IStyleable's styles from the specified Object.
		 */
		function unapplyTo(target:Object):IStyleable;
		
		/**
		 * Merges the specified object's properties into this IStyleable object.
		 */
		function mergeWith(withObj:Object):IStyleable;
		
		/**
		 * Removes the specified object's properties from this IStyleable object.
		 */
		function unmergeWith(withObj:Object):IStyleable;
		
		function toString():String;
    }
}

