part of chronosgl;

class Mesh extends Node {
  
  RenderingContext gl;
  bool debug=false;
  bool blend=false;
  int blend_sFactor = SRC_ALPHA;
  int blend_dFactor = ONE;
  
  bool drawPoints;
  
  Texture texture;
  Texture texture2;
  
  Buffer verticesBuffer, colorsBuffer, textureCoordBuffer, normalsBuffer, vertexIndexBuffer;
  
  int numItems;
 
  Mesh( MeshData meshData, [this.drawPoints=false]) {
    this.texture = meshData.texture;
    this.texture2 = meshData.texture2;
    
    gl = ChronosGL.globalGL;

    verticesBuffer = gl.createBuffer();
    gl.bindBuffer(ARRAY_BUFFER, verticesBuffer);
    gl.bufferDataTyped(ARRAY_BUFFER, meshData.vertices as Float32List, STATIC_DRAW);

    if( meshData.colors != null ) {
      colorsBuffer = gl.createBuffer();
      gl.bindBuffer(ARRAY_BUFFER, colorsBuffer);
      gl.bufferDataTyped(ARRAY_BUFFER, meshData.colors as Float32List, STATIC_DRAW);
    }

    if( meshData.textureCoords != null ) {
      textureCoordBuffer = gl.createBuffer();
      gl.bindBuffer(ARRAY_BUFFER, textureCoordBuffer);
      gl.bufferDataTyped(ARRAY_BUFFER, meshData.textureCoords as Float32List, STATIC_DRAW);
    }
    
    if( meshData.normals != null ) {
      normalsBuffer = gl.createBuffer();
      gl.bindBuffer(ARRAY_BUFFER, normalsBuffer);
      gl.bufferDataTyped(ARRAY_BUFFER, meshData.normals as Float32List, STATIC_DRAW);
    }
    
    if( meshData.vertexIndices != null ) {
      numItems = meshData.vertexIndices.length;
      vertexIndexBuffer = gl.createBuffer();
      gl.bindBuffer(ELEMENT_ARRAY_BUFFER, vertexIndexBuffer);
      gl.bufferDataTyped(ELEMENT_ARRAY_BUFFER, meshData.vertexIndices as Uint16List, STATIC_DRAW);
    } else {
      numItems = meshData.vertices.length ~/ 3;
    }
    
  }
  
  void clearData() {
    gl.deleteBuffer( verticesBuffer);
    if( colorsBuffer != null ) {
      gl.deleteBuffer( colorsBuffer);
    }
    if( textureCoordBuffer != null ) {
      gl.deleteBuffer( textureCoordBuffer);
    }
    if( normalsBuffer != null ) {
      gl.deleteBuffer( normalsBuffer);
    }
    if( vertexIndexBuffer != null ) {
      gl.deleteBuffer( vertexIndexBuffer);
    }
  }

  // this gets called by Node.draw()
  void draw2( ShaderProgram program) {
    
    if( debug) {
      print( "Mesh: $name");
      print( program.shaderObject.textureSamplerUniform);
      print( drawPoints);
      print( numItems);
      print( mvMatrix.array);
      print( '-----');
      
    }
    
    if( blend) {
      //gl.disable(gl.DEPTH_TEST);
      gl.enable(BLEND);
      gl.blendFunc(blend_sFactor, blend_dFactor);
    }
       
    gl.bindBuffer(ARRAY_BUFFER, verticesBuffer);
    gl.vertexAttribPointer(program.vertexPositionAttribute, 3, FLOAT, false, 0, 0);

    if( program.shaderObject.colorsAttribute != null) {
      gl.bindBuffer(ARRAY_BUFFER, colorsBuffer);
      gl.vertexAttribPointer(program.colorsAttribute, 3, FLOAT, false, 0, 0);
    }

    if( program.shaderObject.textureCoordinatesAttribute != null) {
      gl.bindBuffer(ARRAY_BUFFER, textureCoordBuffer);
      gl.vertexAttribPointer(program.textureCoordAttribute, 2, FLOAT, false, 0, 0);
    }

    if( program.shaderObject.normalAttribute != null) {
      gl.bindBuffer(ARRAY_BUFFER, normalsBuffer);
      gl.vertexAttribPointer(program.normalAttribute, 3, FLOAT, false, 0, 0);
    }

    if( program.shaderObject.textureSamplerUniform != null) {
      gl.activeTexture(TEXTURE0);
      gl.bindTexture(TEXTURE_2D, texture);
      gl.uniform1i(program.samplerUniform, 0);
    }

    if( program.shaderObject.texture2SamplerUniform != null) {
      gl.activeTexture(TEXTURE1);
      gl.bindTexture(TEXTURE_2D, texture2);
      gl.uniform1i(program.sampler2Uniform, 1);
    }

    if( program.shaderObject.transformationMatrixUniform != null) {
      gl.uniformMatrix4fv(program.transformationMatrixUniform, false, matrix.array);
    }

    gl.uniformMatrix4fv(program.mvMatrixUniform, false, mvMatrix.array);
    
    if( drawPoints ) {
      gl.drawArrays(POINTS, 0, numItems);
    } else if( vertexIndexBuffer == null) {
      gl.drawArrays(TRIANGLES, 0, numItems);
    } else  {
      gl.bindBuffer(ELEMENT_ARRAY_BUFFER, vertexIndexBuffer);
      gl.drawElements(TRIANGLES, numItems, UNSIGNED_SHORT, 0);
    }
    
    if( debug)
      print( gl.getProgramInfoLog(program.program));
    
    if( blend) {
      //gl.enable(gl.DEPTH_TEST);
      gl.disable(BLEND);
    }
    
    
  }

  
}