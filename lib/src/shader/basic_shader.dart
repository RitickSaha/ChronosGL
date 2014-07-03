part of chronosgl;

@deprecated
ShaderObject createBasicShader() {
  return createTexturedShader();
}

ShaderObject createTexturedShader() {
  ShaderObject shaderObject = new ShaderObject("Textured");
  
  shaderObject.vertexPositionAttribute = "aVertexPosition"; 
  shaderObject.textureCoordinatesAttribute = "aTextureCoord";
  shaderObject.modelViewMatrixUniform = "uMVMatrix";
  shaderObject.perpectiveMatrixUniform = "uPMatrix";
  shaderObject.textureSamplerUniform = "uSampler";
  shaderObject.fragmentShaderBody = "gl_FragColor = texture2D(uSampler, vaTextureCoord);";
  return generateShader(shaderObject);
}

ShaderObject createColorShader() {
  ShaderObject shaderObject = new ShaderObject("Color");
  shaderObject.vertexPositionAttribute = "aVertexPosition"; 
  shaderObject.colorsAttribute = "aColor";
  shaderObject.modelViewMatrixUniform = "uMVMatrix";
  shaderObject.perpectiveMatrixUniform = "uPMatrix";
  shaderObject.fragmentShaderBody = "gl_FragColor = vec4( vaColor, 1.0 );";
  return generateShader(shaderObject);
}

ShaderObject createLightShader() {
  ShaderObject shaderObject = new ShaderObject("Light");
  
  shaderObject.vertexShader = """
        precision mediump float;

        attribute vec3 aVertexPosition;
        attribute vec3 aNormal;
        
        uniform mat4 uMVMatrix;
        uniform mat4 uPMatrix;

        vec3 lightDir = vec3(1.0,0.0,1.0);
        vec3 ambientColor = vec3(0.0,0.0,0.0);
        vec3 directionalColor = vec3(1.0,1.0,1.0);

        vec3 pointLightLocation = vec3( 40, 0, 100);
        
        varying vec3 vLightWeighting;
        varying vec3 vNormal;

        void main(void) {
          gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
          vNormal = (uMVMatrix * vec4(aNormal, 0.0)).xyz;
          pointLightLocation = (uMVMatrix * vec4(pointLightLocation, 0.0)).xyz;

          vec3 lightDir = normalize(pointLightLocation - aVertexPosition.xyz);

          float directionalLightWeighting = max(dot(vNormal, normalize(lightDir)), 0.0);
          vLightWeighting = ambientColor + directionalColor * directionalLightWeighting;
        }
        """;
  
  shaderObject.fragmentShader = """
        precision mediump float;
        
        varying vec3 vLightWeighting;
        varying vec3 vNormal;

        void main(void) {
          //gl_FragColor = vec4( vNormal * vLightWeighting, 1.0 );
          gl_FragColor = vec4( vLightWeighting, 1.0 );
        }
        """;
  
  shaderObject.vertexPositionAttribute = "aVertexPosition"; 
  shaderObject.normalAttribute = "aNormal";
  shaderObject.modelViewMatrixUniform = "uMVMatrix";
  shaderObject.perpectiveMatrixUniform = "uPMatrix";
  
  return shaderObject;
}

ShaderObject createNormal2ColorShader() {
  ShaderObject shaderObject = new ShaderObject("Normal2Color");
  
  shaderObject.vertexShader = """
        precision mediump float;

        attribute vec3 aVertexPosition;
        attribute vec3 aNormal;
        
        uniform mat4 uMVMatrix;
        uniform mat4 uPMatrix;
        
        varying vec3 vColor;

        void main(void) {
          gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
          vColor=normalize( aNormal / 2.0 + vec3(0.5) );
        }
        """;
  
  shaderObject.fragmentShader = """
        precision mediump float;
        
        varying vec3 vColor;

        void main(void) {
          gl_FragColor = vec4( vColor, 1.0 );
        }
        """;
  
  shaderObject.vertexPositionAttribute = "aVertexPosition"; 
  shaderObject.normalAttribute = "aNormal";
  shaderObject.modelViewMatrixUniform = "uMVMatrix";
  shaderObject.perpectiveMatrixUniform = "uPMatrix";
  
  return shaderObject;
}

ShaderObject createPointSpritesShader() {
  ShaderObject shaderObject = new ShaderObject("PointSprites");

  shaderObject.vertexPositionAttribute = "aVertexPosition"; 
  shaderObject.modelViewMatrixUniform = "uMVMatrix";
  shaderObject.perpectiveMatrixUniform = "uPMatrix";
  shaderObject.textureSamplerUniform = "uSampler";
  shaderObject.vertexShaderBody = "gl_PointSize = 1000.0/gl_Position.z;";
  shaderObject.fragmentShaderBody = "gl_FragColor = texture2D(uSampler, gl_PointCoord);\n gl_FragColor.a = 0.4;\n";
  return generateShader(shaderObject);
}
