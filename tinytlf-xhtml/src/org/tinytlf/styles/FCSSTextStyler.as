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
	import org.tinytlf.model.ITLFNode;
	
	public class FCSSTextStyler extends TextStyler
	{
		[Embed(source="default.css", mimeType="application/octet-stream")]
		private const defaultCSS:Class;
		
		public function FCSSTextStyler()
		{
			style = new defaultCSS().toString();
			// A list of non-inheriting styles. If a style isn't in this list,
			// it's assumed to be an inheriting style.
			setStyle('nonInheritingStyles', 
				{
					margin:null, marginLeft: null, marginRight:null, marginTop:null,
					padding: null, paddingLeft: null, paddingRight:null, paddingTop:null,
					width: null, height: null, 'class': null, id: null, style: null
				});
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
					mergeWith(new FCSSStyleProxy(sheet.getStyle("*")));
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
			if(element is String)
				element = String(element).split(' ');
			if(element is Array)
				return sheet.getStyle.apply(null, element as Array);
			
			return super.describeElement(element);
		}
		
		override public function toString():String
		{
			if(stylesheet)
				return stylesheet;
			
			return super.toString();
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
		fd.fontName = style.fontName || style.fontFamily || '_sans';
		
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
