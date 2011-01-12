/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.styles
{
	/**
	 * An interface for an object that has styles.
	 */
    public interface IStyleAware
    {
		/**
		 * The style property of the IStyleAware implementation. Often times 
		 * this object stores the key/value style pairs, but can also support 
		 * wholesale style application and overloading.
		 */
        function get style():Object;
        function set style(value:Object):void;
        
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
		 * Applies this IStyleAware's styles to the specified Object.
		 */
		function applyTo(target:Object):void;
		
		/**
		 * Unapplies this IStyleAware's styles from the specified Object.
		 */
		function unapplyTo(target:Object):void;
		
		/**
		 * Merges the specified object's properties into this IStyleAware object.
		 */
		function mergeWith(withObj:Object):void;
		
		/**
		 * Removes the specified object's properties from this IStyleAware object.
		 */
		function unmergeWith(withObj:Object):void;
		
		/**
		 * toString of course. duh.
		 */
		function toString():String;
    }
}

