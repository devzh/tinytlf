package org.tinytlf.extensions.fcss
{
    import flash.text.engine.ElementFormat;
    
    import org.flexunit.Assert;
    import org.tinytlf.ITextEngine;
    import org.tinytlf.TextEngine;
    import org.tinytlf.styles.FCSSTextStyler;
    
    public class FCSSTextStylerTest
    {
        private var engine:ITextEngine;
        private var styler:FCSSTextStyler;
        private var css:XML = <_><![CDATA[
            *{
                fontName: Times;
                fontSize: 26;
                fontWeight: normal;
            }
            #someID{
                fontName: SomeIdFont;
            }
            .someClass{
                fontName: SomeClassFont;
            }
            b{
                fontWeight: bold;
            }
            .normal{
                fontWeight: normal;
            }
            #redColor{
                color: #FF0000;
            }
        ]]></_>;
        
        [Before]
        public function setUp():void
        {
            engine = new TextEngine();
            styler = new FCSSTextStyler();
            engine.styler = styler;
            styler.style = css.toString();
        }
        
        [After]
        public function tearDown():void
        {
            engine = null;
            styler = null;
        }
		
		[Test]
		public function dummy():void
		{
		}
    }
}