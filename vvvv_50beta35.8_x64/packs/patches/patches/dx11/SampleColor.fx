//define particle properties
#include "particle_struct.fxh"

bool emit;

Texture2D tex <string uiname="ForceField_2D";>;
SamplerState g_samLinear : IMMUTABLE
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Clamp;
    AddressV = Clamp;
};

// emitter position
StructuredBuffer<float3> EmitterPos;

// buffer which holds particle objects
RWStructuredBuffer<particle> Output : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(1, 1, 1)]
void CSConstantForce( uint3 index : SV_DispatchThreadID )
{
	if (emit)
	{
		//Load EmitPos from Buffer
		float3 pos_world = Output[index.x].pos;
		//Convert EmitPos to TexCords
		float2 pos_tex = ((pos_world.xy * float2(0.5,-0.5)) + 0.5);
		//Load Force from ForceField2D
		float4 col = tex.SampleLevel(g_samLinear,(pos_tex),0);
		//Set Color to Buffer
		Output[index.x].col = col;
	}
}

technique10 ColorSampler
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}




