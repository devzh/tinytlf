/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.styles
{
	import com.flashartofwar.fcss.styles.IStyle;
	import com.flashartofwar.fcss.stylesheets.FStyleSheet;
	
	import flash.text.engine.*;
	
	import org.tinytlf.layout.factories.XMLModel;
	
	public class FCSSTextStyler extends TextStyler
	{
		[Embed(source="default.css", mimeType="application/octet-stream")]
		private const defaultCSS:Class;
		
		public function FCSSTextStyler()
		{
			style = new defaultCSS().toString();
		}
		
		private var sheet:FStyleSheet;
		private var stylesheet:String;
		
		override public function set style(value:Object):void
		{
			if(value is String)
			{
				if(!sheet)
					sheet = new TinytlfStyleSheet();
				
				stylesheet = String(value);
				sheet.parseCSS(stylesheet);
				
				//Add the global styles onto this ITextStyler dude.
				
				if(super.style is FCSSStyleProxy)
				{
					merge(new FCSSStyleProxy(sheet.getStyle("*")));
					value = super.style;
				}
				else
				{
					value = new FCSSStyleProxy(sheet.getStyle("*"));
				}
			}
			
			super.style = value;
		}
		
		override public function getElementFormat(element:*):ElementFormat
		{
			var format:ElementFormat = new ElementFormat();
			var description:FontDescription = new FontDescription();
			
			if(element is Array)
				element = Vector.<XMLModel>(element);
			if(element is XMLModel)
				element = new <XMLModel>[XMLModel(element)];
			if(element is Vector.<XMLModel>)
				element = computeStyles(element);
			if(element)
			{
				new EFApplicator().applyStyle(format, element);
				new FDApplicator().applyStyle(description, element);
				format.fontDescription = description;
			}
			
			return format;
		}
		
		override public function describeElement(element:*):Object
		{
			if(element is Array)
				element = Vector.<XMLModel>(element);
			if(element is XMLModel)
				element = new <XMLModel>[XMLModel(element)];
			if(element is Vector.<XMLModel>)
			{
				var context:Vector.<XMLModel> = Vector.<XMLModel>(element);
				var obj:IStyleAware = new StyleAwareActor(super.describeElement(context[context.length - 1].name));
				obj.style = computeStyles(context);
				
				return obj;
			}
			else
			{
				return super.describeElement(element);
			}
		}
		
		override public function toString():String
		{
			if(stylesheet)
				return stylesheet;
			
			return super.toString();
		}
		
		/**
		 * Constructs an array of styleNames to pass to F*CSS for style parsing.
		 * Returns an F*CSS IStyle object.
		 */
		protected function computeStyles(context:Vector.<XMLModel>):IStyle
		{
			var node:XMLModel;
			var attr:String;
			
			var i:int = 0;
			var n:int = context.length;
			
			var className:String;
			var idName:String;
			var uniqueNodeName:String;
			
			// initialize to 'a:a' so that F*CSS has something to parse if there
			// aren't any inline styles.
			var inlineStyle:String = 'a:a;';
			//Start with *, because everything inherits from *.
			var inheritanceStructure:Array = ['*'];
			
			var str:String = '';
			
			for(i = 0; i < n; i++)
			{
				node = context[i];
				
				if(node.stylesDirty)
				{
					str += node.name;
					
					//Math.random() times one trillion. Reasonably safe for unique identification... right? ;)
					uniqueNodeName = ' ' + node.name + String(Math.round(Math.random() * 100000000000000));
					
					for(attr in node)
					{
						if(attr == 'class')
							className = node[attr];
						else if(attr == 'id')
							idName = node[attr];
						else if(attr == 'style')
							inlineStyle += node[attr];
						else if(attr == 'cssState' && node[attr] != '')
							str += ':' + node[attr];
						else if(attr != 'unique')
							inlineStyle += (attr + ': ' + node[attr] + ";");
					}
					
					if(className)
						str += " ." + className;
					if(idName)
						str += " #" + idName;
					if(uniqueNodeName)
					{
						str += uniqueNodeName;
						sheet.parseCSS(uniqueNodeName + '{' + inlineStyle + '}');
					}
					
					node.styleString = str;
					node.stylesDirty = false;
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
			
			return sheet.getStyle.apply(null, inheritanceStructure);
		}
	}
}

import com.flashartofwar.fcss.applicators.AbstractApplicator;
import com.flashartofwar.fcss.styles.IStyle;
import com.flashartofwar.fcss.stylesheets.FStyleSheet;
import com.flashartofwar.fcss.utils.TypeHelperUtil;

import flash.text.engine.*;

import org.tinytlf.styles.FCSSStyleProxy;

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

internal class TinytlfStyleSheet extends FStyleSheet
{
	override protected function createEmptyStyle():IStyle
	{
		return new FCSSStyleProxy();
	}
}
