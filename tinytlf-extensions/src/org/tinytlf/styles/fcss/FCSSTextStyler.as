/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.styles.fcss
{
	import com.flashartofwar.fcss.styles.IStyle;
	import com.flashartofwar.fcss.stylesheets.FStyleSheet;
	
	import flash.text.engine.*;
	import flash.utils.Dictionary;
	
	import org.tinytlf.layout.model.factories.xhtml.XMLDescription;
	import org.tinytlf.styles.IStyleAware;
	import org.tinytlf.styles.StyleAwareActor;
	import org.tinytlf.styles.TextStyler;
	
	public class FCSSTextStyler extends TextStyler
	{
		public function FCSSTextStyler()
		{
			const L:String = '{';
			const R:String = '}';
			const sheet:XMLList =
				<>
					*{L}
						fontLookup: {FontLookup.DEVICE};
						fontName: _sans;
						fontSize: 12;
					{R}
					h1{L}
						fontSize: 30;
					{R}
					b{L}
						fontWeight: bold;
					{R}
					i{L}
						fontPosture: italic;
					{R}
					em{L}
						fontPosture: italic;
					{R}
					ul{L}
						paddingTop: 10;
						paddingBottom: 10;
						listStylePosition: inside;
					{R}
				</>;
			style = sheet.toString();
		}
		
		override public function set style(value:Object):void
		{
			if(value is String)
			{
				var sheet:FStyleSheet = new FStyleSheet();
				sheet.parseCSS(value as String);
				value = new FStyleProxy(sheet);
				
				//Add the global styles onto this ITextStyler dude.
				FStyleProxy(value).style = sheet.getStyle("*");
			}
			
			super.style = value;
		}
		
		override public function getElementFormat(element:*):ElementFormat
		{
			var format:ElementFormat = new ElementFormat();
			var description:FontDescription = new FontDescription();
			
			if(element is Array)
			{
				element = Vector.<XMLDescription>(element);
			}
			
			if(element is Vector.<XMLDescription>)
			{
				var fStyle:IStyle = computeStyles(Vector.<XMLDescription>(element));
				new EFApplicator().applyStyle(format, fStyle);
				new FDApplicator().applyStyle(description, fStyle);
				format.fontDescription = description;
			}
			
			return format;
		}
		
		override public function describeElement(element:*):Object
		{
			if(element is Array)
			{
				element = Vector.<XMLDescription>(element);
			}
			if(element is XMLDescription)
			{
				element = new <XMLDescription>[XMLDescription(element)];
			}
			
			if(element is Vector.<XMLDescription>)
			{
				var context:Vector.<XMLDescription> = Vector.<XMLDescription>(element);
				var obj:Object = super.describeElement(context[context.length - 1].name) || {};
				obj = new StyleAwareActor(obj);
				IStyleAware(obj).style = computeStyles(context);
				return obj;
			}
			else
			{
				return super.describeElement(element);
			}
		}
		
		protected function computeStyles(context:Vector.<XMLDescription>):IStyle
		{
			//  Context is the currently processing XML node 
			//  and its parents, with attributes.
			
			var node:XMLDescription;
			var attributes:Object;
			var attr:String;
			
			var i:int = 0;
			var n:int = context.length;
			
			var className:String;
			var idName:String;
			var uniqueNodeName:String;
			var inlineStyle:String = 'a:a;';
			var inheritanceStructure:Array = ['*'];
			
			var str:String = '';
			
			for(i = 0; i < n; i++)
			{
				node = context[i];
				
				if(node.reprocess())
				{
					if(node.name)
						str += node.name;
					
					if(node.attributes)
					{
						attributes = node.attributes;
						
						//Math.random() times one trillion. Reasonably safe for unique identification... right? ;)
						uniqueNodeName = ' ' + node.name + String(Math.round(Math.random() * 100000000000000));
						
						for(attr in attributes)
						{
							if(attr == 'class')
								className = attributes[attr];
							else if(attr == 'id')
								idName = attributes[attr];
							else if(attr == 'style')
								inlineStyle += attributes[attr];
							else if(attr == 'cssState' && attributes[attr] != '')
								str += ':' + attributes[attr];
							else if(attr != 'unique')
								inlineStyle += (attr + ': ' + attributes[attr] + ";");
						}
					}
					
					if(className)
						str += " ." + className;
					if(idName)
						str += " #" + idName;
					if(uniqueNodeName)
					{
						str += uniqueNodeName;
						FStyleProxy(style).sheet.parseCSS(uniqueNodeName + '{' + inlineStyle + '}');
					}
					
					node.styleString = str;
					node.doneProcessing();
				}
				else
				{
					str = node.styleString;
				}
				
				inheritanceStructure = inheritanceStructure.concat(str.split(' '));
				
				str = '';
				className = '';
				idName = '';
				uniqueNodeName = '';
				inlineStyle = 'a:a;';
			}
			
			return FStyleProxy(style).sheet.getStyle.apply(null, inheritanceStructure);
		}
	}
}

import com.flashartofwar.fcss.applicators.AbstractApplicator;
import com.flashartofwar.fcss.utils.TypeHelperUtil;

import flash.text.engine.BreakOpportunity;
import flash.text.engine.CFFHinting;
import flash.text.engine.DigitCase;
import flash.text.engine.DigitWidth;
import flash.text.engine.ElementFormat;
import flash.text.engine.FontDescription;
import flash.text.engine.FontLookup;
import flash.text.engine.FontPosture;
import flash.text.engine.FontWeight;
import flash.text.engine.Kerning;
import flash.text.engine.LigatureLevel;
import flash.text.engine.RenderingMode;
import flash.text.engine.TextBaseline;
import flash.text.engine.TextRotation;
import flash.text.engine.TypographicCase;

internal class EFApplicator extends AbstractApplicator
{
	public function EFApplicator()
	{
		super(this);
	}
	
	override public function applyStyle(target:Object, style:Object):void
	{
		if(!(target is ElementFormat))
			throw new ArgumentError('The target of an EFApplicator must be an ElementFormat!');
		
		var ef:ElementFormat = ElementFormat(target);
		ef.alignmentBaseline = style.alignmentBaseline || TextBaseline.USE_DOMINANT_BASELINE;
		ef.alpha = valueFilter(style.alpha || '1', 'number');
		ef.baselineShift = valueFilter(style.baselineShift || '0', 'number');
		ef.breakOpportunity = style.breakOpportunity || BreakOpportunity.AUTO;
		ef.color = valueFilter(style.color || '0x00', 'uint');
		ef.digitCase = style.digitCase || DigitCase.DEFAULT;
		ef.digitWidth = style.digitWidth || DigitWidth.DEFAULT;
		ef.dominantBaseline = style.dominantBaseline || TextBaseline.ROMAN;
		ef.fontSize = valueFilter(style.fontSize || '12', 'number');
		ef.kerning = style.kerning || Kerning.AUTO;
		ef.ligatureLevel = style.ligatureLevel || LigatureLevel.COMMON;
		ef.locale = style.locale || 'en_US';
		ef.textRotation = style.textRotation || TextRotation.AUTO;
		ef.trackingLeft = valueFilter(style.trackingLeft || '0', 'number');
		ef.trackingRight = valueFilter(style.trackingRight || '0', 'number');
		ef.typographicCase = style.typographicCase || TypographicCase.DEFAULT;
	}
	
	override protected function valueFilter(value:String, type:String):*
	{
		return TypeHelperUtil.getType(value, type);
	}
}

internal class FDApplicator extends AbstractApplicator
{
	public function FDApplicator()
	{
		super(this);
	}
	
	override public function applyStyle(target:Object, style:Object):void
	{
		if(!(target is FontDescription))
			throw new ArgumentError('The target of an FDApplicator must be a FontDescription!');
		
		var fd:FontDescription = FontDescription(target);
		
		fd.cffHinting = style.cffHinting || CFFHinting.HORIZONTAL_STEM;
		fd.fontLookup = style.fontLookup || FontLookup.EMBEDDED_CFF;
		fd.fontName = style.fontName || style.fontfamily || '_sans';
		
		if('fontStyle' in style)
			fd.fontPosture = style.fontStyle == FontPosture.ITALIC ? FontPosture.ITALIC : FontPosture.NORMAL;
		fd.fontPosture = style.fontPosture || fd.fontPosture;
		
		fd.fontWeight = style.fontWeight || FontWeight.NORMAL;
		fd.renderingMode = style.renderingMode || RenderingMode.CFF;
	}
	
	override protected function valueFilter(value:String, type:String):*
	{
		return TypeHelperUtil.getType(value, type);
	}
}
