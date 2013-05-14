/*
* Copyright (c) 2012 the original author or authors
*
* Permission is hereby granted to use, modify, and distribute this file
* in accordance with the terms of the license agreement accompanying it.
*/
package org.tinytlf
{
	import asx.array.filter;
	import asx.array.map;
	import asx.array.reduce;
	import asx.fn.I;
	import asx.fn.aritize;
	import asx.fn.not;
	import asx.object.merge;
	import asx.string.empty;
	
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	
	import trxcllnt.Store;
	
	use namespace flash_proxy;
	
	public class CSS extends Proxy
	{
		[Embed(source = "default.css", mimeType = "application/octet-stream")]
		public static const defaultCSS:Class;
		
		public function CSS(css:String = '')
		{
			super();
			clearStyles();
			inject(css || '');
		}
		
		private var styles:StyleStore;
		
		/**
		 * Queries for all properties derived from the given style path. The
		 * style path should aggregate the nodes, class names, ids, and
		 * pseudoclasses, and sort them in inheritance order (from left to
		 * right).
		 *
		 * @returns An <code>Object</code> that represents a flattened list of
		 * all cascading styles defined by the style path.
		 */
		public function lookup(path:String):Object
		{
			return Cache.getStyle(path) || Cache.cacheStyle(path, internalLookup(path));
		}
		
		//	#id
		//	.class
		//	body p
		//	body p a:active
		//	body p#id a:active
		//	body p #id a:active
		//	body p.class a:active
		//	body p .class a:active
		//	div a#id:active
		//	div a.class:active
		private function internalLookup(path:String):Object
		{
			if(!path) return {};
			
			const chains:Array = map(path.split(' '), Cache.getName);
			const stores:Array = reduce([styles], chains, function(parents:Array, chain:StyleChain):Array {
				return parents.concat(reduce([], parents, function(stores:Array, parent:StyleStore):Array {
					return stores.concat(filter(map(chain, parent.getDescendent), I));
				}));
			}) as Array;
			
			return merge.apply(null, [new Store()].concat(stores));
		}
		
		/**
		 * Parse and inject any number of CSS blocks. CSS blocks can be as
		 * simple as:
		 * <p><code>
		 *	a {
		 *		color: black;
		 *	}
		 * </code></p>
		 * to as complex as:
		 * <p><code>
		 *	h1,div#content,div#content a,span.title_link,
		 *	span.title_link a,span.title_link a:hover,li a,
		 *	#banner img{
		 *		color:#494949;
		 *		text-shadow:1 1 0 #fff;
		 *	}
		 * </code></p>
		 */
		public function inject(css:String):CSS
		{
			// Strip out all white space between blocks
			css.replace(/\s*([@{}:;,]|\)\s|\s\()\s*|\/\*([^*\\\\]|\*(?!\/))+\*\/|[\n\r\t]/g, '$1').
				// Parse each block
				match(/[^{]*\{([^}]*)*}/g).
				forEach(function(block:String, ... args):void {
					if(!block)return;
					
					// Split the block into two parts: prefix and suffix.
					// prefix is the block style names, suffix is the values.
					const parts:Array = block.split('{');
					const suffix:String = parts.pop().split('}')[0];
					const prefix:String = parts.pop();
					
					// The suffix is easy, build a hashmap of key/value pairs.
					const values:Store = new Store();
					
					suffix.split(';').
						filter(aritize(not(empty), 1)).
						forEach(function(pair:String, ... args):void {
							const parts:Array = pair.split(':');
							values[parts.shift()] = parts.pop();
						});
					
					// Prefix is trickier. Split on the commas, because comma is
					// the style aggregation token. A prefix of 'h1, h2' means
					// apply this block's values to the top level style
					// dictionary of both h1 and h2, without a cascading
					// relationship.
					prefix.split(',').
						filter(aritize(not(empty), 1)).
						// The StyleName class encapsulates the cascading
						// relationship for styles, and stores them in a
						// sorted styles array.
						map(aritize(Cache.getName, 1)).
						forEach(function(chain:StyleChain, ... args):void {
							
							// Start indexing style names at the root.
							var link:StyleStore = styles;
							
							// Iterate through the sorted cascading styles list
							// and move/create nodes for the descendent styles
							// at each level.
							// Apply the values once we've reached the lowest
							// level of the style tree.
							chain.forEach(function(name:String, i:int, a:Array):void {
								link = link.createDescendent(name);
								// link = (link.descendents[name] ||= new StyleStore());
								
								if(i == a.length - 1) merge(link, values);
							});
						});
					});
			
			return this;
		}
		
		public function clearStyles():Object
		{
			Cache.clearStyles();
			styles = new StyleStore();
			inject(new defaultCSS().toString());
			return this;
		}
		
		override flash_proxy function getProperty(name:*):*
		{
			return styles[name];
		}
		
		override flash_proxy function setProperty(name:*, value:*):void
		{
			styles[name] = value;
		}
	}
}
import asx.array.anyOf;
import asx.object.merge;

import flash.utils.Proxy;
import flash.utils.flash_proxy;

import trxcllnt.Store;

use namespace flash_proxy;

internal class StyleStore extends Store
{
	public function StyleStore()
	{
		super();
	}
	
	override flash_proxy function setProperty(name:*, value:*):void
	{
		super.setProperty(convertFromDashed(name.toString()), value);
	}
	
	override flash_proxy function getProperty(name:*):*
	{
		return super.getProperty(convertFromDashed(name.toString()));
	}
	
	private function convertFromDashed(property:String):String
	{
		return property.split('-').map(function(part:String, i:int, ... args):String {
			return i == 0 ? part : part.charAt(0).toUpperCase() + part.substr(1);
		}).join('');
	}
	
	public function getDescendent(component:String):StyleStore {
		return descendents[component];
	}
	
	public function createDescendent(component:String):StyleStore {
		return descendents[component] ||= new StyleStore();
	}
	
	public const descendents:Store = new Store();
	
	private static const defaults:Object = {
		padding: 0, paddingLeft: 0, paddingRight: 0, paddingTop: 0,
		paddingBottom: 0, margin: 0, marginLeft: 0, marginRight: 0,
		marginTop: 0, marginBottom: 0, //width: '100%', height: '100%',
		fontSize: 12, leading: 0, paragraphSpacing: 0, fontMultiplier: 1
	};
}

internal dynamic class StyleChain extends Array
{
	////
	//	Style will be in any of the following formats.
	//	div#footer
	//	div.post_content
	//	a:active
	//	div a:active
	//	#banners img
	//	.posts .post
	//	li a
	//	li a:active
	//	li a.posts:active
	//	
	//	TODO: nth-child and not: pseudo selectors
	//	div#footer.foo:nth-child(2n)
	//	div.foo#footer:not(:active, .post_content):nth-child(2n)
	////
	public function StyleChain(chain:String)
	{
		super();
		
		const build:Function = function(component:String, token:String):Array {
			
			const i:int = component.lastIndexOf(token);
			
			if(i == -1) return [];
			
			const prefix:String = component.substring(0, i);
			const suffix:String = component.substring(i);
			
			return Cache.getName(prefix).concat(Cache.getName(suffix));
		};
		
		const tokens:Array = [':', '.', '#'];
		
		chain.split(' ').forEach(function(component:String, ...args):* {
			
			const hasToken:Boolean = anyOf(tokens, function(token:String):Boolean {
				
				if(component.lastIndexOf(token) < 1) return false;
				
				return push.apply(null, build(component, token)) > 0;
			});
			
			return hasToken ? null : push(component);
		});
	}
}

internal class Cache
{
	public static function clearStyles():void
	{
		styleCache = {};
	}
	
	private static const nameCache:Object = {};
	public static function getName(name:String):StyleChain
	{
		return nameCache[name] ||= new StyleChain(name);
	}
	
	private static var styleCache:Object = {};
	public static function getStyle(lookup:String):Object
	{
		return styleCache[lookup];
	}
	
	public static function cacheStyle(path:String, style:Object):Object
	{
		return styleCache[path] = style;
	}
}