module Svgl.Tree exposing (..)

import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Svgl.Primitives as Primitives exposing (defaultUniforms)
import WebGL exposing (Mesh, Shader)


type alias Transform =
    -- TODO: turn into `type Transform = Translate Vec3 | Rotate Float`?
    { translate : Vec3
    , rotate : Float
    }


type alias Entity =
    WebGL.Entity


type Node
    = Ent (Mat4 -> Entity)
    | Nod (List Transform) (List Node)


treeToEntities : Mat4 -> Node -> List ( Mat4, Entity )
treeToEntities worldToCamera node =
    recursiveTreeToEntities node worldToCamera []


applyTransform : Transform -> Mat4 -> Mat4
applyTransform t mat =
    mat
        |> Mat4.translate t.translate
        |> Mat4.rotate t.rotate (vec3 0 0 -1)


recursiveTreeToEntities : Node -> Mat4 -> List ( Mat4, Entity ) -> List ( Mat4, Entity )
recursiveTreeToEntities node transformSoFar entitiesSoFar =
    case node of
        Ent matToEntity ->
            ( transformSoFar, matToEntity transformSoFar ) :: entitiesSoFar

        Nod transforms children ->
            let
                newTransform =
                    List.foldl applyTransform transformSoFar transforms
            in
            List.foldr (\child enli -> recursiveTreeToEntities child newTransform enli) entitiesSoFar children



--
{-
   raise : Float -> Node -> Node
   raise dz node =
       case node of
           Nod transforms children ->
               Nod transforms (List.map (raise dz) children)

           end ->
             ent
               Ent (f >> Tuple.mapFirst ((+) dz))


   raiseList : Float -> List Node -> Node
   raiseList dz list =
       raise dz (Nod [] list)
-}
--


translate : Vec2 -> Transform
translate v =
    { translate = vec3 (Vec2.getX v) (Vec2.getY v) 0
    , rotate = 0
    }


translateVz : Vec2 -> Float -> Transform
translateVz v z =
    { translate = vec3 (Vec2.getX v) (Vec2.getY v) z
    , rotate = 0
    }


translate2 : Float -> Float -> Transform
translate2 x y =
    { translate = vec3 x y 0
    , rotate = 0
    }


rotateRad : Float -> Transform
rotateRad radians =
    { translate = vec3 0 0 0
    , rotate = radians
    }


rotateDeg : Float -> Transform
rotateDeg =
    degrees >> rotateRad


type alias Params =
    { x : Float
    , y : Float
    , z : Float
    , rotate : Float
    , w : Float
    , h : Float
    , fill : Vec3
    , stroke : Vec3
    , strokeWidth : Float
    , opacity : Float
    }


defaultParams : Params
defaultParams =
    { x = 0
    , y = 0
    , z = 0
    , rotate = 0
    , w = 1
    , h = 1
    , fill = Primitives.defaultUniforms.fill
    , stroke = Primitives.defaultUniforms.stroke
    , strokeWidth = 0.025
    , opacity = 1
    }


entity : (Primitives.Uniforms -> WebGL.Entity) -> Params -> Node
entity primitive p =
    Nod
        [ { translate = vec3 p.x p.y 0 --p.z
          , rotate = p.rotate
          }
        ]
        [ Ent
            (\entityToCamera ->
                primitive
                    { defaultUniforms
                        | entityToCamera = entityToCamera
                        , dimensions = vec2 p.w p.h
                        , fill = p.fill
                        , stroke = p.stroke
                        , strokeWidth = p.strokeWidth
                        , opacity = p.opacity
                    }
            )
        ]


rect : Params -> Node
rect =
    entity Primitives.rect


ellipse : Params -> Node
ellipse =
    entity Primitives.ellipse
