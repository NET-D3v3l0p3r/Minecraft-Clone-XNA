//-----------------------------------------------------------------------------
// InstancedModel.fx
//
// Microsoft XNA Community Game Platform
// Copyright (C) Microsoft Corporation. All rights reserved.
//-----------------------------------------------------------------------------


// Camera settings.
float4x4 World;
float4x4 View;
float4x4 Projection;


// This sample uses a simple Lambert lighting model.
float3 LightDirection = normalize(float3(-1, -1, -1));
float3 DiffuseLight = 1.25;
float3 AmbientLight = 0.35;


sampler Sampler0 : register(s0);
sampler Sampler1 : register(s1);
sampler Sampler2 : register(s2);
sampler Sampler3 : register(s3);
sampler Sampler4 : register(s4);
sampler Sampler5 : register(s5);
sampler Sampler6 : register(s6);
sampler Sampler7 : register(s7);
sampler Sampler8 : register(s8);
sampler Sampler9 : register(s9);
sampler Sampler10 : register(s10);
sampler Sampler11 : register(s11);
sampler Sampler12 : register(s12);
sampler Sampler13 : register(s13);
sampler Sampler14 : register(s14);
sampler Sampler15 : register(s15);


float     FogEnabled;
float     FogStart;
float     FogEnd;
float3    FogColor;


uniform const float3    DiffuseColor = 1;
uniform const float     Alpha = 1;
uniform const float3    EmissiveColor = 0;
uniform const float3    SpecularColor = 1;
uniform const float     SpecularPower = 1;
uniform const float3    EyePosition;


struct VertexShaderInput
{
	float4 Position : POSITION0;
	float3 Normal : NORMAL0;
	float2 TextureCoordinate : TEXCOORD0;
};


struct VertexShaderOutput
{
	float4 Position : POSITION0;
	float4 Color : COLOR0;
	float2 TextureCoordinate : TEXCOORD0;
	float2 IndexCoord : TEXCOORD1;
	float4  Specular    : COLOR2;
};

float ComputeFogFactor(float d)
{
	return clamp((d - FogStart) / (FogEnd - FogStart), 0, 1) * FogEnabled;
}

VertexShaderOutput VertexShaderCommon(VertexShaderInput input, float4x4 instanceTransform, float2 index)
{
	VertexShaderOutput output;

	// Apply the world and camera matrices to compute the output position.
	float4 worldPosition = mul(input.Position, instanceTransform);
	float4 viewPosition = mul(worldPosition, View);
	output.Position = mul(viewPosition, Projection);

	// Compute lighting, using a simple Lambert model.
	float3 worldNormal = mul(input.Normal, instanceTransform);
	float diffuseAmount = max(-dot(worldNormal, LightDirection), 0);
	float3 lightingResult = saturate(diffuseAmount * DiffuseLight + AmbientLight);

	output.Color = float4(lightingResult.rgb + EmissiveColor, 1);
	output.Specular = float4(0, 0, 0, ComputeFogFactor(length(EyePosition - worldPosition)));

	// Copy across the input texture coordinate.
	output.TextureCoordinate = input.TextureCoordinate;
	output.IndexCoord = index;
	return output;
}


// Hardware instancing reads the per-instance world transform from a secondary vertex stream.
VertexShaderOutput HardwareInstancingVertexShader(VertexShaderInput input,
	float4x4 instanceTransform : BLENDWEIGHT0, float2 index : TEXCOORD1)
{
	return VertexShaderCommon(input, mul(World, transpose(instanceTransform)), index);
}

// Both techniques share this same pixel shader.
float4 PixelShaderFunction(VertexShaderOutput input) : COLOR0
{
	float4 tex = float4(0, 0, 0, 0);
	//2010 2015
	if (input.IndexCoord.x > -1 && input.IndexCoord.x < 1)  //01
		tex = tex2D(Sampler0, input.TextureCoordinate);
	if (input.IndexCoord.x > 1 && input.IndexCoord.x <  3)   //02
		tex = tex2D(Sampler1, input.TextureCoordinate);
	if (input.IndexCoord.x > 3 && input.IndexCoord.x <  5)   //04
		tex = tex2D(Sampler2, input.TextureCoordinate);
	if (input.IndexCoord.x > 5 && input.IndexCoord.x <  7)   //06
		tex = tex2D(Sampler3, input.TextureCoordinate);
	if (input.IndexCoord.x > 7 && input.IndexCoord.x <  9)   //08
		tex = tex2D(Sampler4, input.TextureCoordinate);
	if (input.IndexCoord.x > 9 && input.IndexCoord.x <  11)  //10
		tex = tex2D(Sampler5, input.TextureCoordinate);
	if (input.IndexCoord.x > 11 && input.IndexCoord.x < 13) //12
		tex = tex2D(Sampler6, input.TextureCoordinate);
	if (input.IndexCoord.x > 13 && input.IndexCoord.x < 15) //14
		tex = tex2D(Sampler7, input.TextureCoordinate);
	if (input.IndexCoord.x > 15 && input.IndexCoord.x < 17) //16
		tex = tex2D(Sampler8, input.TextureCoordinate);
	if (input.IndexCoord.x > 17 && input.IndexCoord.x < 19) //18
		tex = tex2D(Sampler9, input.TextureCoordinate);
	if (input.IndexCoord.x > 19 && input.IndexCoord.x < 21) //20
		tex = tex2D(Sampler10, input.TextureCoordinate);
	if (input.IndexCoord.x > 21 && input.IndexCoord.x < 23) //22
		tex = tex2D(Sampler11, input.TextureCoordinate);
	if (input.IndexCoord.x > 23 && input.IndexCoord.x < 25) //24
		tex = tex2D(Sampler12, input.TextureCoordinate);
	if (input.IndexCoord.x > 25 && input.IndexCoord.x < 27) //26
		tex = tex2D(Sampler13, input.TextureCoordinate);
	if (input.IndexCoord.x > 27 && input.IndexCoord.x < 29) //28
		tex = tex2D(Sampler14, input.TextureCoordinate);
	if (input.IndexCoord.x > 29 && input.IndexCoord.x < 31) //30
		tex = tex2D(Sampler15, input.TextureCoordinate);

	tex *= input.Color + float4(input.Specular.rgb, 0);
	tex.rgb = lerp(tex.rgb, FogColor, input.Specular.w);

	return tex;

}

technique HardwareInstancing
{
	pass Pass1
	{
		VertexShader = compile vs_3_0 HardwareInstancingVertexShader();
		PixelShader = compile ps_3_0 PixelShaderFunction();
	}

}
