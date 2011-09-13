package embeds
{
	import flash.utils.ByteArray;

	[Embed(source="assets/html/idlewords.txt", mimeType="application/octet-stream")]
//	[Embed(source = "assets/html/lipsum.txt", mimeType = "application/octet-stream")]
//	[Embed(source = "assets/html/link.txt", mimeType = "application/octet-stream")]
	public class HTMLSource extends ByteArray
	{
		public function HTMLSource()
		{
		}
	}
}