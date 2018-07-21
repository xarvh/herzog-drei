module Svgl.Primitives exposing (Uniforms, ellipse, rect)

import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import WebGL exposing (Entity, Mesh, Shader)
import WebGL.Settings exposing (Setting)
import WebGL.Settings.Blend as Blend


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


settings : List Setting
settings =
    [ Blend.add Blend.srcAlpha Blend.oneMinusSrcAlpha ]


rect : Uniforms -> Entity
rect =
    WebGL.entityWith settings quadVertexShader rectFragmentShader normalizedQuadMesh


ellipse : Uniforms -> Entity
ellipse =
    WebGL.entityWith settings quadVertexShader ellipseFragmentShader normalizedQuadMesh


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


        float smoothEllipse(vec2 position, vec2 radii) {
          float x = position.x;
          float y = position.y;
          float w = radii.x;
          float h = radii.y;

          float xx = x * x;
          float yy = y * y;
          float ww = w * w;
          float hh = h * h;

          // We will need the assumption that we are not too far from the ellipse
          float ew = w + e;
          float eh = h + e;

          if ( xx / (ew * ew) + yy / (eh * eh) > 1.0 ) {
            return 1.0;
          }

          /*
          Given an ellipse Q with radii W and H, the ellipse P whose every point
          has distance D from the closest point in A is given by:

            x^2       y^2
          ------- + ------- = 1
          (W+D)^2   (H+D)^2

          Assuming D << W and D << H we can solve for D dropping the terms in
          D^3 and D^4.
          We obtain: a * d^2 + b * d + c = 0
          */

          float c = xx * hh + yy * ww - ww * hh;
          float b = 2.0 * (h * xx + yy * w - h * ww - w * hh);
          float a = xx + yy - ww - hh - 4.0 * w * h;

          float delta = sqrt(b * b - 4.0 * a * c);
          //float solution1 = (-b + delta) / (2.0 * a);
          float solution2 = (-b - delta) / (2.0 * a);

          return smoothstep(-e, e, solution2);
        }


        void main () {
          vec2 strokeSize = dimensions / 2.0;
          vec2 fillSize = strokeSize - strokeWidth;

          float alpha = 1.0 - smoothEllipse(localPosition, strokeSize);
          float fillVsStroke = 1.0 - smoothEllipse(localPosition, fillSize);

          vec3 color = mix(fill, stroke, fillVsStroke);

          gl_FragColor = vec4(color, alpha);
        }
    |]
