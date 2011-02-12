package org.tinytlf.extensions.xml.layout.factory
{
    import flash.text.engine.TextBlock;
    
    import org.flexunit.assertThat;
    import org.tinytlf.ITextEngine;
    import org.tinytlf.TextEngine;
    
    public class XMLBlockFactoryTests
    {
        private var engine:ITextEngine;
        
        [Before]
        public function setUp():void
        {
            engine = new TextEngine();
        }
        
        [After]
        public function tearDown():void
        {
        }
        
        [BeforeClass]
        public static function setUpBeforeClass():void
        {
        }
        
        [AfterClass]
        public static function tearDownAfterClass():void
        {
        }
        
        [Test]
        public function paragraph_node_creates_one_text_block():void
        {
            trace('break here');
            engine.blockFactory.data = "<p>Text</p>";
            engine.prerender();
            var blocks:Vector.<TextBlock> = engine.blockFactory.blocks;
            assertThat(blocks.length == 1);
        }
    }
}