import 'package:chronosgl/chronosgl.dart';
import 'dart:html' as HTML;
import 'dart:typed_data';
import 'package:vector_math/vector_math.dart' as VM;

final ShaderObject instancedVertexShader = new ShaderObject("InstancedV")
  ..AddAttributeVars([aPosition])
  ..AddAttributeVars([iaRotation, iaTranslation])
  ..AddVaryingVars([vColor])
  ..AddUniformVars([uPerspectiveViewMatrix, uModelMatrix])
  ..SetBody([
    """
vec3 rotate_vertex_position(vec3 pos, vec4 rot) { 
    return pos + 2.0 * cross(rot.xyz, cross(rot.xyz, pos) + rot.w * pos);
}

void main(void) {
    vec3 P = rotate_vertex_position(${aPosition}, ${iaRotation}) +
             ${iaTranslation};
    gl_Position = ${uPerspectiveViewMatrix} * ${uModelMatrix} * vec4(P, 1);
    ${vColor} = vec3(sin(${aPosition}.x)/2.0+0.5,
                     cos(${aPosition}.y)/2.0+0.5, 
                     sin(${aPosition}.z)/2.0+0.5);
}
"""
  ]);

final ShaderObject instancedFragmentShader = new ShaderObject("InstancedF")
  ..AddVaryingVars([vColor])
  ..SetBodyWithMain(["${oFragColor} = vec4( ${vColor}, 1. );"]);

Scene MakeStarScene(ChronosGL cgl, UniformGroup perspective, int num) {
  Scene scene = new Scene(
      "stars",
      new RenderProgram(
          "stars", cgl, pointSpritesVertexShader, pointSpritesFragmentShader),
      [perspective]);
  scene.add(Utils.MakeParticles(scene.program, num));
  return scene;
}

void AddInstanceData(MeshData md) {
  int count = 1000;
  Float32List translations = new Float32List(count * 3);
  Float32List rotations = new Float32List(count * 4);

  Spatial spatial = new Spatial("dummy");
  int pos = 0;
  for (int x = -5; x < 5; x++) {
    for (int y = -5; y < 5; y++) {
      for (int z = -5; z < 5; z++) {
        spatial.setPos(x * 40.0, y * 40.0, z * 30.0);
        translations.setAll(pos * 3, spatial.getPos().storage);
        VM.Quaternion q =
            new VM.Quaternion.fromRotation(spatial.transform.getRotation());
        rotations.setAll(pos * 3, q.storage);
        pos++;
      }
    }
  }

  md.AddAttribute(iaRotation, rotations, 4);
  md.AddAttribute(iaTranslation, translations, 3);
}

void main() {
  StatsFps fps =
      new StatsFps(HTML.document.getElementById("stats"), "blue", "gray");
  HTML.CanvasElement canvas = HTML.document.querySelector('#webgl-canvas');

  ChronosGL cgl = new ChronosGL(canvas, faceCulling: true);
  OrbitCamera orbit = new OrbitCamera(265.0, 0.0, 0.0, canvas);
  Perspective perspective = new Perspective(orbit, 0.1, 1000.0);

  final RenderPhaseResizeAware phase =
      new RenderPhaseResizeAware("main", cgl, canvas, perspective);
  Scene scene = new Scene(
      "instanced",
      new RenderProgram(
          "instanced", cgl, instancedVertexShader, instancedFragmentShader),
      [perspective]);
  phase.add(scene);

  Material mat = new Material("mat");
  MeshData md = ShapeTorusKnot(scene.program, radius: 12.0);
  AddInstanceData(md);
  scene.add(new Node("torus", md, mat));

  phase.add(MakeStarScene(cgl, perspective, 2000));

  double _lastTimeMs = 0.0;
  void animate(num timeMs) {
    double elapsed = timeMs - _lastTimeMs;
    _lastTimeMs = timeMs + 0.0;
    orbit.azimuth += 0.001;
    orbit.animate(elapsed);
    phase.Draw();

    HTML.window.animationFrame.then(animate);
    fps.UpdateFrameCount(_lastTimeMs);
  }

  animate(0.0);
}
