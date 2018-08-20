
//define particle properties
#include "particle_struct.fxh"
#include "NoiseFunction.fxh"

RWStructuredBuffer<particle> Output : BACKBUFFER;

//NOISE FORCE:
float3 noise_amount;
float noise_time;
int noise_oct;
float noise_freq = 1;
float noise_lacun = 1.666;
float noise_pers = 0.666;

//==============================================================================
// COMPUTE SHADER ==============================================================
//==============================================================================

[numthreads(128, 1, 1)]
void CSnoiseF( uint3 DTid : SV_DispatchThreadID )
{
	float3 pos = Output[DTid.x].pos;
	// Noise Force
	float3 noiseF = float3(	fBm(float4(pos+float3(51,2.36,-5),noise_time),noise_oct,noise_freq,noise_lacun,noise_pers),
							fBm(float4(pos+float3(98.2,-9,-36),noise_time),noise_oct,noise_freq,noise_lacun,noise_pers),
							fBm(float4(pos+float3(0,10.69,6),noise_time),noise_oct,noise_freq,noise_lacun,noise_pers));

	Output[DTid.x].acc += noiseF * noise_amount;
}

//==============================================================================
// TECHNIQUES ==================================================================
//==============================================================================

technique11 NoiseForce
{
	pass P0s
	{
	SetComputeShader( CompileShader( cs_5_0, CSnoiseF() ) );
	}
}




