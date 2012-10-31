package org.tinytlf.layout.box.paragraph
{
	import org.tinytlf.layout.box.alignment.IAlignment;
	import org.tinytlf.layout.box.progression.IProgression;

	public interface IParagraphLayout
	{
		function get progression():IProgression;
		function set progression(value:IProgression):void;
		
		function layout(lines:Array, paragraph:Paragraph):Array/*<TextLine>*/;
	}
}