module Svgl.Primitives exposing (..)

import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Math.Vector4 as Vec4 exposing (Vec4, vec4)
import WebGL exposing (Entity, Mesh, Shader)



type alias Attributes =
    { position : Vec2 }


type alias Uniforms =
    { entityToCamera : Mat4
    , dimensions : Vec2
    , fill : Vec4
    , stroke : Vec4
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
    WebGL.entity rectVertexShader rectFragmentShader normalizedQuadMesh


rectVertexShader : Shader Attributes Uniforms Varying
rectVertexShader =
    [glsl|
        precision mediump float;

        attribute vec2 position;

        uniform mat4 entityToCamera;
        uniform vec2 dimensions;
        uniform vec4 fill;
        uniform vec4 stroke;
        uniform float strokeWidth;

        varying vec2 localPosition;

        void main () {
            localPosition = (dimensions + vec2(strokeWidth, strokeWidth)) * position;
            gl_Position = entityToCamera * vec4(localPosition, 0, 1);
        }
    |]


rectFragmentShader : Shader {} Uniforms Varying
rectFragmentShader =
    [glsl|
        precision mediump float;

        uniform mat4 entityToCamera;
        uniform vec2 dimensions;
        uniform vec4 fill;
        uniform vec4 stroke;
        uniform float strokeWidth;

        varying vec2 localPosition;

        void main () {
            if ( localPosition.x > strokeWidth - dimensions.x / 2.0
              && localPosition.x < -strokeWidth + dimensions.x / 2.0
              && localPosition.y > strokeWidth - dimensions.y / 2.0
              && localPosition.y < -strokeWidth + dimensions.y / 2.0
              )
              gl_FragColor = fill;
            else
              gl_FragColor = stroke;
        }
    |]
