module Svgl.Tree exposing (..)

import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Svgl.Primitives as Primitives
import WebGL exposing (Entity, Mesh, Shader)


type alias Transform =
    { translateX : Float
    , translateY : Float
    , rotate : Float
    }


type Node
    = Ent (Mat4 -> Entity)
    | Nod (List Transform) (List Node)


treeToEntities : Mat4 -> Node -> List Entity
treeToEntities worldToCamera node =
    recursiveTreeToEntities node worldToCamera []


applyTransform : Transform -> Mat4 -> Mat4
applyTransform t mat =
    mat
        |> Mat4.translate3 t.translateX t.translateY 0
        |> Mat4.rotate t.rotate (vec3 0 0 -1)


recursiveTreeToEntities : Node -> Mat4 -> List Entity -> List Entity
recursiveTreeToEntities node transformSoFar entitiesSoFar =
    case node of
        Ent matToEntity ->
            matToEntity transformSoFar :: entitiesSoFar

        Nod transforms children ->
            let
                newTransform =
                    List.foldl applyTransform transformSoFar transforms
            in
            List.foldr (\child enli -> recursiveTreeToEntities child newTransform enli) entitiesSoFar children



--


translate : Vec2 -> Transform
translate v =
    { translateX = Vec2.getX v
    , translateY = Vec2.getY v
    , rotate = 0
    }


translate2 : Float -> Float -> Transform
translate2 x y =
    { translateX = x
    , translateY = y
    , rotate = 0
    }


rotateRad : Float -> Transform
rotateRad radians =
    { translateX = 0
    , translateY = 0
    , rotate = radians
    }


type alias Params =
    { x : Float
    , y : Float
    , rotate : Float
    , w : Float
    , h : Float
    , fill : Vec3
    , stroke : Vec3
    }


entity : (Primitives.Uniforms -> Entity) -> Params -> Node
entity primitive p =
    Nod
        [ { translateX = p.x
          , translateY = p.y
          , rotate = p.rotate
          }
        ]
        [ Ent
            (\entityToCamera ->
                primitive
                    { entityToCamera = entityToCamera
                    , dimensions = vec2 p.w p.h
                    , fill = p.fill
                    , stroke = p.stroke
                    , strokeWidth = 0.03
                    }
            )
        ]


rect : Params -> Node
rect =
    entity Primitives.rect


ellipse : Params -> Node
ellipse =
    entity Primitives.ellipse
