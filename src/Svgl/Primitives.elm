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

        // TODO: transform into `pixelSize`, make it a uniform
        float pixelsPerTile = 30.0;
        float e = 1.0 / pixelsPerTile;

        /*
         *     0               1                            1                     0
         *     |------|--------|----------------------------|----------|----------|
         *  -edge-e  -edge  -edge+e                      edge-e      edge      edge+e
         */
        float mirrorStep (float edge, float p) {
          return smoothstep(-edge - e, -edge + e, p) - smoothstep(edge - e, edge + e, p);
        }

        void main () {
          vec2 strokeSize = dimensions / 2.0;
          vec2 fillSize = dimensions / 2.0 - strokeWidth;

          float alpha = mirrorStep(strokeSize.x, localPosition.x) * mirrorStep(strokeSize.y, localPosition.y);
          float fillVsStroke = mirrorStep(fillSize.x, localPosition.x) * mirrorStep(fillSize.y, localPosition.y);
          vec3 color = mix(fill, stroke, fillVsStroke);

          gl_FragColor = vec4(color, alpha);
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

        // TODO: transform into `pixelSize`, make it a uniform
        float pixelsPerTile = 30.0;
        float e = 1.0 / pixelsPerTile;

        /*
         *     0               1                            1                     0
         *     |------|--------|----------------------------|----------|----------|
         *  -edge-e  -edge  -edge+e                      edge-e      edge      edge+e
         */
        float mirrorStep (float edge, float p) {
          return smoothstep(-edge - e, -edge + e, p) - smoothstep(edge - e, edge + e, p);
        }

        void main () {
          float x = localPosition.x / 0.5;
          float y = localPosition.y / 0.5;
          float w = dimensions.x / 2.0;
          float h = dimensions.y / 2.0;

          float xx = x * x;
          float yy = y * y;
          float ww = w * w;
          float hh = h * h;

          float c = xx * hh + yy * ww - ww * hh;
          float b = 2.0 * (h * xx + yy * w - h * ww - w * hh);
          float a = xx + yy - ww - hh - 4.0 * w * h;

          float delta = sqrt(b * b - 4.0 * a * c);
          float s1 = (-b + delta) / (2.0 * a);
          float s2 = (-b - delta) / (2.0 * a);

          // distance from the ellipse border
          float d = max(s1, s2);

          float q = 1.0 - smoothstep(-e, e, d);

          float p = (xx / ww + yy / hh < 1.0) ? 0.0 : 0.50;

          gl_FragColor = vec4(q, 0.0, 0.0, 1.0);
        }
    |]
