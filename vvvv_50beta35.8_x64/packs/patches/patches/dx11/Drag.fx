//define particle properties
#include "particle_struct.fxh"

float dragC;
float miny;
StructuredBuffer<float4> AttractorPosition;
// buffer which holds particle objects
RWStructuredBuffer<particle> Output : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================
void ApplyForce (float3 force, uint index)
{
	Output[index].acc = force;
}

[numthreads(128, 1, 1)]
void CSConstantForce( uint3 index : SV_DispatchThreadID )
{
	if (Output[index.x].pos.y < miny)
	{
		float3 drag = Output[index.x].vel * -1;
		drag *= dragC/10;
		ApplyForce(drag, index.x);
	}
}

technique10 Emitter
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}




