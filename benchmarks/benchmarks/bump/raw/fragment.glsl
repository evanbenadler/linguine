precision mediump float;

vec3 to_sRGB(vec3 c) { return pow(c, vec3(1.0/2.2, 1.0/2.2, 1.0/2.2)); }
vec3 from_sRGB(vec3 c) { return pow(c, vec3(2.2, 2.2, 2.2)); }
uniform sampler2D uDiffuseTexture;
uniform sampler2D uDisplacementMap;
uniform float uDisplacementScale;
varying vec2 vUv;
varying vec3 vNormal;
varying vec3 vPosition;
varying mat3 vNormalMatrix;
// varying vec3 vDerivU;
// varying vec3 vDerivV;
void main() {
    float displacementScale = -10.;
    vec3 vDerivV = vec3(1.0, -1.0, 1.0);
    vec3 vDerivU = vec3(-1.0, 1.0, -1.0);
    // Compute displaced normals as in the
    // displacement vertex shader, and use them for shading.
    // Lastly, implement Phong reflectance function.
    float delta = 0.001;
    // Approximate the partial derivatives of a texture
    vec2 d_u = vec2(delta, 0.);
    vec2 d_v = vec2(0., delta);
    vec4 dh_du = (texture2D(uDisplacementMap, vUv - d_u) - texture2D(uDisplacementMap, vUv + d_u)) / (2.0 * delta);
    vec4 dh_dv = (texture2D(uDisplacementMap, vUv - d_v) - texture2D(uDisplacementMap, vUv + d_v)) / (2.0 * delta);
    
    // Calculate derivatives of the surface
    vec4 t_u = vec4(vDerivU, 0.) + uDisplacementScale * dh_du * vec4(vNormal, 0.);
    vec4 t_v = vec4(vDerivV, 0.) + uDisplacementScale * dh_dv * vec4(vNormal, 0.);
    
    // Calculate displaced normal
    vec3 dispNorm = cross(vec3(t_u), vec3(t_v));
    dispNorm = normalize(vNormalMatrix * dispNorm);
    // interpolating normals will change the length of the normal, so renormalize the normal.
    vec3 N = normalize(dispNorm);
    vec3 V = normalize(-vPosition);
    
    float roughness = 0.2;
    vec3 finalColor = vec3(0.0, 0.0, 0.0);
    vec3 lightPosition = vec3(1., 1., 1.);
    vec3 lightColor = vec3(0.1, 0.3, 0.5);
    for (int i = 0; i <= 1; i += 1) {
        float r = length(lightPosition - vPosition);
        vec3 L = normalize(lightPosition - vPosition);
        vec3 H = normalize(L + V);
        // calculate diffuse term
        vec3 Idiff = from_sRGB(vec3(texture2D(uDiffuseTexture, vUv))) * max(dot(N, L), 0.2);
        // calculate specular term
        vec3 Ispec = vec3(1.0, 1.0, 1.0) * pow(max(dot(N, H), 0.0), 1.0 / roughness);
        finalColor = finalColor + lightColor * ((Idiff + Ispec)) / (r*r);
        lightPosition = vec3(-1., -1., -1.);
    }

    float exposure = 10.;
    // Only shade if facing the light
    // Color the back faces an identifiable color
    if (gl_FrontFacing) {
        gl_FragColor = vec4(to_sRGB(finalColor * exposure), 1.0);
    } else {
        gl_FragColor = vec4(170.0/255.0, 160.0/255.0, 0.0, 1.0);
    }
}