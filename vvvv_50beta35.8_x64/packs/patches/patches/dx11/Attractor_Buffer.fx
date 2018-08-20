//define particle properties
#include "particle_struct.fxh"

//float force;
//float3 attPos;
//float size;
int CountAttractor;
StructuredBuffer<float3> AttractorPosition;
StructuredBuffer<float2> ForceSize;
// buffer which holds particle objects
RWStructuredBuffer<particle> Output : BACKBUFFER;

//==============================================================================
//COMPUTE SHADER ===============================================================
//==============================================================================

[numthreads(128, 1, 1)]
void CSConstantForce( uint3 index : SV_DispatchThreadID )
{
	for(int i = 0; i < CountAttractor; i++)
	{
	float3 dist = AttractorPosition[i] - Output[index.x].pos;
	float f = (length(dist) / ForceSize[i].y);
	f = 1-f;
	f = saturate (f);
	f = pow (f, 2.71);
	Output[index.x].acc += dist * f * ForceSize[i].x;
	}
}

technique10 Emitter
{
	pass P0
	{
		SetComputeShader( CompileShader( cs_5_0, CSConstantForce() ) );
	}
}




