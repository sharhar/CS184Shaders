#version 120

#include "distort.glsl"

varying vec2 texCoords;
varying vec4 color;

void main(){
    gl_Position    = ftransform();
    gl_Position.xy = DistortPosition(gl_Position.xy);
    texCoords = gl_MultiTexCoord0.st;
    color = gl_Color;
}