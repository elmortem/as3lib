package karma.starling.extensions {
	
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3D;
	import flash.display.Bitmap;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.VertexBuffer3D;
	
	import starling.display.Image;
	import starling.textures.Texture;
	import starling.textures.TextureSmoothing;
	import starling.core.RenderSupport;
	import starling.core.Starling;
	import starling.utils.VertexData;
	import starling.errors.MissingContextError;
	
	/**
	 *
	 * @author Sword.Tao <a href="mailto:minoswind@gmail.com">minoswind@gmail.com</a>
	 *
	 */
	public class BlendImage extends Image {
		
		/** Helper object. */
		private static var sRenderAlpha:Vector.<Number> = new <Number>[1.0, 1.0, 1.0, 1.0];
		
		private var mIndices:Vector.<uint>;
		private var mIndexBuffer:IndexBuffer3D;
		private var mVertexBuffer:VertexBuffer3D;
		
		private var mBlendMode:String;
		private var mBlendFactorSource:String;
		private var mBlendFactorDestination:String;
		
		public function BlendImage(texture:Texture) {
			
			super(texture);
			
			mBlendFactorSource = Context3DBlendFactor.ONE;
			mBlendFactorDestination = Context3DBlendFactor.ZERO;
			
			var context:Context3D = Starling.context;
			
			mVertexBuffer = context.createVertexBuffer(4, VertexData.ELEMENTS_PER_VERTEX);
			mVertexBuffer.uploadFromVector(mVertexData.rawData, 0, 4);
			
			mIndices = new <uint>[];
			mIndices.fixed = false;
			mIndices.push(0, 1, 2, 1, 3, 2);
			mIndices.fixed = true;
			
			mIndexBuffer = context.createIndexBuffer(6);
			mIndexBuffer.uploadFromVector(mIndices, 0, 6);
			
			//blendMode = "normal";
		}
		
		public override function dispose():void {
			if (mVertexBuffer)
				mVertexBuffer.dispose();
			if (mIndexBuffer)
				mIndexBuffer.dispose();
			
			super.dispose();
		}
		
		/** Creates an Image with a texture that is created from a bitmap object. */
		public static function fromBitmap(bitmap:Bitmap):BlendImage {
			return new BlendImage(Texture.fromBitmap(bitmap));
		}
		
		/**
		 * blendMode
		 */
		public function set blendMode(mode:String):void {
			if (mode == "add") {
				mBlendFactorSource = Context3DBlendFactor.ONE;
				mBlendFactorDestination = Context3DBlendFactor.ONE;
			} else if (mode == "light") {
				mBlendFactorSource = Context3DBlendFactor.SOURCE_ALPHA;
				mBlendFactorDestination = Context3DBlendFactor.ONE;
			} else if (mode == "alpha") {
				mBlendFactorSource = Context3DBlendFactor.ZERO;
				mBlendFactorDestination = Context3DBlendFactor.SOURCE_ALPHA;
			} else if (mode == "multiply") {
				mBlendFactorSource = Context3DBlendFactor.ZERO;
				mBlendFactorDestination = Context3DBlendFactor.SOURCE_COLOR;
			} else if (mode == "zero") {
				mBlendFactorSource = Context3DBlendFactor.ONE;
				mBlendFactorDestination = Context3DBlendFactor.ZERO;
			} else if (mode == "light_alpha") {
				mBlendFactorSource = Context3DBlendFactor.DESTINATION_COLOR;
				mBlendFactorDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			} else {
				mBlendFactorSource = Context3DBlendFactor.ONE;
				mBlendFactorDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
			}
			mBlendMode = mode;
		}
		
		/**
		 * blendMode
		 */
		public function get blendMode():String {
			return mBlendMode;
		}
		
		/** @inheritDoc */
		public override function render(support:RenderSupport, alpha:Number):void {
			
			// always call this method when you write custom rendering code!
			// it causes all previously batched quads/images to render.
			support.finishQuadBatch();
			
			alpha *= this.alpha;
			var dynamicAlpha:Boolean = alpha != 1.0;
			
			var program:String = BlendImage.getImageProgramName(dynamicAlpha, mTexture.mipMapping, mTexture.repeat, mSmoothing);
			var context:Context3D = Starling.context;
			var pma:Boolean = texture.premultipliedAlpha;
			
			sRenderAlpha[0] = sRenderAlpha[1] = sRenderAlpha[2] = pma ? alpha : 1.0;
			sRenderAlpha[3] = alpha;
			
			if (context == null)
				throw new MissingContextError();
			
			mVertexBuffer.uploadFromVector(mVertexDataCache.rawData, 0, 4);
			mIndexBuffer.uploadFromVector(mIndices, 0, 6);
			
			context.setBlendFactors(mBlendFactorSource, mBlendFactorDestination);
			
			context.setProgram(Starling.current.getProgram(program));
			context.setVertexBufferAt(0, mVertexBuffer, VertexData.POSITION_OFFSET, Context3DVertexBufferFormat.FLOAT_3);
			context.setVertexBufferAt(1, mVertexBuffer, VertexData.COLOR_OFFSET, Context3DVertexBufferFormat.FLOAT_4);
			context.setVertexBufferAt(2, mVertexBuffer, VertexData.TEXCOORD_OFFSET, Context3DVertexBufferFormat.FLOAT_2);
			
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, support.mvpMatrix, true);
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, sRenderAlpha, 1);
			context.setTextureAt(0, mTexture.base);
			
			context.drawTriangles(mIndexBuffer, 0, 2);
			
			context.setTextureAt(0, null);
			context.setVertexBufferAt(0, null);
			context.setVertexBufferAt(1, null);
			context.setVertexBufferAt(2, null);
		}
		
		// program management
		private static function getImageProgramName(dynamicAlpha:Boolean, mipMap:Boolean = true, repeat:Boolean = false, smoothing:String = "bilinear"):String {
			// this method is designed to return most quickly when called with
			// the default parameters (no-repeat, mipmap, bilinear)
			
			var name:String = dynamicAlpha ? "QB_i*" : "QB_i'";
			
			if (!mipMap)
				name += "N";
			if (repeat)
				name += "R";
			if (smoothing != TextureSmoothing.BILINEAR)
				name += smoothing.charAt(0);
			
			return name;
		}
	}
}