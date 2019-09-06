module Main exposing (main)

import Browser
import Debug
import Generated.Api as BE
import Html as H
import Html.Attributes as HA
import Html.Attributes.Aria as HAA
import Html.Events as HE
import Http
import RemoteData exposing (RemoteData)
import Session
import Utils


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type Msg
    = HandleLoginResp (Result Http.Error String)
    | SetLoginUsername String
    | SetLoginPassword String
    | LoginSubmit


type alias Model =
    { token : Maybe String
    , loginErrorMessage : Maybe String
    , loginUsername : String
    , loginPassword : String
    }


init : flags -> ( Model, Cmd Msg )
init _ =
    ( { token = Nothing
      , loginErrorMessage = Nothing
      , loginUsername = ""
      , loginPassword = ""
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update action model =
    case action of
        HandleLoginResp (Ok token) ->
            ( { model | token = Just token }, Cmd.none )

        HandleLoginResp (Err err) ->
            ( { model | loginErrorMessage = Just "Backend login failed" }, Cmd.none )

        SetLoginUsername s ->
            ( { model | loginUsername = s }, Cmd.none )

        SetLoginPassword s ->
            ( { model | loginPassword = s }, Cmd.none )

        LoginSubmit ->
            ( { model | token = Nothing, loginErrorMessage = Nothing }
            , BE.postApiLogin (BE.DbPlayer model.loginUsername model.loginPassword) HandleLoginResp
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> H.Html Msg
view model =
    H.div [ HA.class "login-box" ]
        [ H.h1 [] [ H.text "Login" ]
        , H.form [ HE.onSubmit LoginSubmit ]
            [ H.input
                [ HA.placeholder "Player Id"
                , HAA.ariaLabel "Player ID"
                , HE.onInput SetLoginUsername
                ]
                []
            , H.input
                [ HA.placeholder "Password"
                , HA.type_ "password"
                , HAA.ariaLabel "Password"
                , HE.onInput SetLoginPassword
                ]
                []
            , H.button
                [ HA.class "btn primary" ]
                [ H.text "Login" ]
            , case model.token of
                Nothing ->
                    H.text ""

                Just t ->
                    H.pre [] [ H.text t ]
            , case model.loginErrorMessage of
                Nothing ->
                    H.text ""

                Just err ->
                    H.p [ HA.class "err" ] [ H.text err ]
            ]
        ]
