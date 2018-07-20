module Svgl.Primitives exposing (..)

import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import WebGL exposing (Entity, Mesh, Shader)



type alias Attributes =
    { position : Vec2 }


type alias Uniforms =
    { entityToCamera : Mat4
    , dimensions : Vec2
    , fill : Vec3
    , stroke : Vec3
    , strokeWidth : Float
    }


type alias Varying =
    { localPosition : Vec2 }


normalizedQuadMesh : Mesh Attributes
normalizedQuadMesh =
    WebGL.triangles
        [ ( Attributes (vec2 -0.5 -0.5)
          , Attributes (vec2 0.5 -0.5)
          , Attributes (vec2 0.5 0.5)
          )
        , ( Attributes (vec2 -0.5 -0.5)
          , Attributes (vec2 -0.5 0.5)
          , Attributes (vec2 0.5 0.5)
          )
        ]


rect : Uniforms -> Entity
rect =
    WebGL.entity quadVertexShader rectFragmentShader normalizedQuadMesh


ellipse : Uniforms -> Entity
ellipse =
    WebGL.entity quadVertexShader ellipseFragmentShader normalizedQuadMesh


quadVertexShader : Shader Attributes Uniforms Varying
quadVertexShader =
    [glsl|
        precision mediump float;

        attribute vec2 position;

        uniform mat4 entityToCamera;
        uniform vec2 dimensions;
        uniform vec3 fill;
        uniform vec3 stroke;
        uniform float strokeWidth;

        varying vec2 localPosition;

        void main () {
            localPosition = (dimensions + strokeWidth) * position;
            gl_Position = entityToCamera * vec4(localPosition, 0, 1);
        }
    |]


rectFragmentShader : Shader {} Uniforms Varying
rectFragmentShader =
    [glsl|
        precision mediump float;

        uniform mat4 entityToCamera;
        uniform vec2 dimensions;
        uniform vec3 fill;
        uniform vec3 stroke;
        uniform float strokeWidth;

        varying vec2 localPosition;

        float e = 5.0 / 30.0;

        void main () {
          vec2 strokeSize = dimensions / 2.0;
          vec2 fillSize = dimensions / 2.0 - strokeWidth;


          if (localPosition.x < -fillSize.x) {
            float ax = smoothstep( -e - strokeSize.x, e - strokeSize.x, localPosition.x);
            gl_FragColor = vec4(stroke, ax);
          } else {
            float ax = smoothstep( -e - fillSize.x, e - fillSize.x, localPosition.x);
            gl_FragColor = vec4(mix(stroke, fill, ax), 1.0);
          }
        }
    |]

ellipseFragmentShader : Shader {} Uniforms Varying
ellipseFragmentShader =
    [glsl|
        precision mediump float;

        uniform mat4 entityToCamera;
        uniform vec2 dimensions;
        uniform vec3 fill;
        uniform vec3 stroke;
        uniform float strokeWidth;

        varying vec2 localPosition;

        void main () {
          float xx = localPosition.x * localPosition.x;
          float yy =  localPosition.y * localPosition.y;
        }
    |]
