part of chronosgl;

class ChronosFramebuffer {
  WEBGL.RenderingContext gl;
  int width;
  int height;

  WEBGL.Framebuffer framebuffer;
  WEBGL.Renderbuffer renderbuffer;
  TextureWrapper colorTexture;
  TextureWrapper depthTexture;
  var depthTextureExt;

  ChronosFramebuffer(this.gl, this.width, this.height) {
    depthTextureExt = GetGlExtensionDepth(gl);
    // http://blog.tojicode.com/2012/07/using-webgldepthtexture.html
    if (depthTextureExt == null) {
      throw "Error";
    }

    framebuffer = gl.createFramebuffer();

    colorTexture =
        new TextureWrapper.Null("frame::color", width, height, false);
    colorTexture.Install(gl);
    depthTexture = new TextureWrapper.Null("frame::depth", width, height, true);
    depthTexture.Install(gl);

    gl.bindFramebuffer(WEBGL.FRAMEBUFFER, framebuffer);
    gl.framebufferTexture2D(WEBGL.FRAMEBUFFER, WEBGL.COLOR_ATTACHMENT0, WEBGL.TEXTURE_2D,
        colorTexture.GetTexture(), 0);
    gl.framebufferTexture2D(
        WEBGL.FRAMEBUFFER, WEBGL.DEPTH_ATTACHMENT, WEBGL.TEXTURE_2D, depthTexture.GetTexture(), 0);

    gl.bindTexture(WEBGL.TEXTURE_2D, null);
    gl.bindFramebuffer(WEBGL.FRAMEBUFFER, null);
  }

  bool ready() {
    bool result =
        gl.checkFramebufferStatus(WEBGL.FRAMEBUFFER) == WEBGL.FRAMEBUFFER_COMPLETE;
    if (!result) {
      print("FRAMEBUFFER_INCOMPLETE");
    }
    return result;
  }
}
